class Admin::UsersController < Admin::BaseController
  skip_authorization_check :only => [:create, :new]
  before_action :load_user, only: :create
  load_and_authorize_resource

  def index
    if params[:agency_id]
      @agency = Agency.find(params[:agency_id]) 
      @users = @agency.users
    else
      @users = User.all.sort
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  def new
    @user = User.new
  end

  def create
    usr = params[:user]
    @user = User.new
    @user.first_name = usr[:first_name]
    @user.last_name = usr[:last_name]
    @user.email = usr[:email]
    @user.password = @user.password_confirmation = SecureRandom.urlsafe_base64(16)
    @user.save

    if usr[:agency]
      agency = Agency.find(usr[:agency])
      unless agency
        flash[:alert] = 'Agency not found'
        redirect_to :back
      end
      @agency_user_relationship = AgencyUserRelationship.new  #defaults to Status = 3, i.e. Active
      @agency_user_relationship.user = @user || get_traveler
      @agency_user_relationship.agency = agency
      @agency_user_relationship.creator = current_user.id
      @agency_user_relationship.save
    end

    if @agency_user_relationship.valid? and @user.valid?
        UserMailer.agency_helping_email(@agency_user_relationship.user.email, @agency_user_relationship.user.email, agency).deliver
        flash[:notice] = t(:agency_added)
    
        session.delete(:agency)
      unless current_user.has_role? :system_administrator
        session.delete(:agency)
        agency_staff_impersonate(@agency_user_relationship.user.id, @agency_user_relationship.agency.id)
        redirect_to new_user_trip_path(@user)
      else
        flash[:notice] = t(:user_created_and_added_to_agency, user: @user.email, agency: agency.try(:name))
        redirect_to(:back)
      end
    else # user.update_attributes
      redirect_to :back
    end
  end

  def add_to_agency
    agency = Agency.find(params[:agency_id])
    params[:agency][:user_ids].reject{|u| u.blank?}.each do |user_id|
      u = User.find(user_id)
      u.agency = agency
      u.save
    end
    redirect_to admin_agency_users_path(agency)
  end

  def update_roles
    agency = Agency.find(params[:user][:agency_id])
    u = User.find(params[:id])
    role_name = params[:user][:role_name]
    unless u.has_role? role_name
      u.roles.each do |role|
        u.remove_role role.name
      end
      u.add_role role_name
      u.save!
    end
    redirect_to admin_agency_users_path(agency)
  end


private 
  def agency_staff_impersonate(user_id, agency_id)
    @agency_user_relationship = AgencyUserRelationship.find_or_create_by(user_id: user_id, agency_id: agency_id) do |aur|
      aur.creator = current_user.id
    end
    set_traveler_id user_id
  end

  # TODO THese from Aaron's changes
  # def user_params
  #   params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
  # end

  # # def aur_params
  # #   params.require(:agency_user_relationship).permit(:approved_agencies)
  # # end

  def load_user
    @user = params.require(:user).permit(:first_name, :last_name, :email, :agency)
  end

end