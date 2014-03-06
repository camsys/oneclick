class Admin::UsersController < Admin::BaseController

  # GET /users
  # GET /users.json
  def index
    #Get the broadest list of user
    if params[:text] != [""]
      @users = User.where("upper(first_name) LIKE ? OR upper(last_name) LIKE ? OR upper(email) LIKE ?", 
      "%#{params[:text].upcase}%", "%#{params[:text].upcase}%", "%#{params[:text].upcase}%")
    else
      @users = User.all
    end
    ##winnow down
    @users = @users.registered if params[:registered]
    @users = @users.delete_if{ |x| x.roles.count > 0} if params[:traveler]
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  def add_to_agency
    puts "ADD_TO_AGENCY"
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

end
