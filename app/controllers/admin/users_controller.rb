class Admin::UsersController < Admin::BaseController
  skip_authorization_check :only => [:create, :new]
  before_action :load_user, only: :create
  before_filter :authenticate_user!, :except => [:agency_assist]
  load_and_authorize_resource
  
  def index
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
    @user.password = usr[:password]
    @user.password_confirmation = usr[:password_confirmation]

    respond_to do |format|
      if @user.save
        @user.add_role :registered_traveler
        if current_user.agency # create agency user relationship if current user is agency staff
          @agency_user_relationship = AgencyUserRelationship.new  #defaults to Status = 3, i.e. Active
          @agency_user_relationship.user = @user # @user should have been guarded above by @user.valid?, assume it exists
          @agency_user_relationship.agency = current_user.agency
          @agency_user_relationship.creator = current_user.id
          
          if @agency_user_relationship.save
            UserMailer.agency_helping_email(@agency_user_relationship.user.email, @agency_user_relationship.agency.email || @agency_user_relationship.agency.name, current_user.agency).deliver
          end
        end
        flash[:notice] = t(:user_created)
        format.html { redirect_to admin_user_path(@user)}
      else # invalid user
        format.html { render action: "new"}
      end
    end
  end
          
  def show
    session[:location] = edit_user_registration_path
    @agency_user_relationship = AgencyUserRelationship.new
    @user_relationship = UserRelationship.new
    @user_characteristics_proxy = UserCharacteristicsProxy.new(@user)
    @user_programs_proxy = UserProgramsProxy.new(@user)
    @user_accommodations_proxy = UserAccommodationsProxy.new(@user)
  end

  def edit
    session[:location] = edit_user_registration_path
    @agency_user_relationship = AgencyUserRelationship.new
    @user_relationship = UserRelationship.new
    @user_characteristics_proxy = UserCharacteristicsProxy.new(@user)
    @user_programs_proxy = UserProgramsProxy.new(@user)
    @user_accommodations_proxy = UserAccommodationsProxy.new(@user)

    respond_to do |format|
      format.html # edit.html.erb
      format.json { render json: @user }
    end
  end

  def update
    @user_characteristics_proxy = UserCharacteristicsProxy.new(@user) #we inflate a new proxy every time, but it's transient, just holds a bunch of characteristics
    
    update_method = params[:password].blank? ? user_params_without_password : user_params_with_password
    if @user.update_attributes!(update_method)
      @user_characteristics_proxy.update_maps(params[:user_characteristics_proxy])
      set_approved_agencies(params[:user][:approved_agency_ids])
      set_buddies(params[:user][:buddy_ids])
      redirect_to admin_user_path(@user, locale: @user.preferred_locale), :notice => "User updated."
    else
      redirect_to admin_user_path(@user), :alert => "Unable to update user."
    end
  end

  # def add_to_agency # no longer applicable, iteration 5 workflow runs from the agency, not the user
  #   agency = Agency.find(params[:agency_id])
  #   params[:agency][:user_ids].reject{|u| u.blank?}.each do |user_id|
  #     u = User.find(user_id)
  #     u.agency = agency
  #     u.save
  #   end
  #   redirect_to admin_agency_users_path(agency)
  # end

  def assist
    authorize! :assist, @user
    set_traveler_id params[:id]
    redirect_to new_user_trip_path(params[:id])
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

  def user_params_without_password
    params.require(:user).permit(:first_name, :last_name, :email, :preferred_locale)
  end

  def user_params_with_password
    params.require(:user).permit(:first_name, :last_name, :email, :preferred_locale, :password, :password_confirmation)
  end

  def load_user
    params[:agency_id] = params[:agency]
    @user = User.new(params.require(:user).permit(:first_name, :last_name, :email, :agency_id))
  end

  def set_approved_agencies(ids)
    new_agency_ids = ids.reject!(&:empty?) # Simple form keeps adding a blank, so strip that out
    old_agency_ids = @user.approved_agencies.pluck(:id).map(&:to_s)  #hack.  Converting to strings for comparison to params hash

    new_relationships = new_agency_ids - old_agency_ids # Any agency set in the params but not the profile
    revoked_agencies = old_agency_ids - new_agency_ids # Any agency set in the profile but not the params
    new_relationships.each do |id| # Create new ones if they don't exist already
      rel = AgencyUserRelationship.find_or_create_by!(user_id: @user.id, agency_id: id) do |aur|
        aur.creator = current_user.id
      end
      #now that we have the relationship object, set it as active/confirmed
      rel.update_attributes(relationship_status: RelationshipStatus.confirmed)
      agency = Agency.find(id)
      UserMailer.agency_helping_email(@user.email, agency.email || agency.name, agency).deliver
    end
    revoked_agencies.each do |revoked_id|
      revoked = AgencyUserRelationship.find_by(agency_id: revoked_id, user_id: @user.id)
      revoked.update_attributes(relationship_status: RelationshipStatus.revoked)
    end
  end

  def set_buddies(ids)
    new_buddy_ids = ids.reject!(&:empty?)
    old_buddy_ids = @user.buddies.pluck(:id).map(&:to_s) #hack.  Converting to strings for comparison to params hash

    new_buddies = new_buddy_ids - old_buddy_ids
    revoked_buddies = old_buddy_ids - new_buddy_ids

    new_buddies.each do |id|
      rel = UserRelationship.find_or_create_by!( traveler: @user, delegate: User.find(id)) do |ur|
        ur.update_attributes(relationship_status: RelationshipStatus.confirmed)
        UserMailer.buddy_request_email(ur.traveler.email, ur.delegate.email).deliver
      end
      rel.update_attributes(relationship_status: RelationshipStatus.confirmed)
    end
  end


end