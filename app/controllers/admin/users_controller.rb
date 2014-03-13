class Admin::UsersController < Admin::BaseController

 def index
    @agency = Agency.find(params[:agency_id]) 
    @users = @agency.users

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