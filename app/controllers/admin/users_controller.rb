class Admin::UsersController < Admin::BaseController
  skip_authorization_check :only => [:create, :new]
  before_action :load_user, only: :create
  before_filter :authenticate_user!, :except => [:agency_assist]
  load_and_authorize_resource

  def index
    usertable = UsersDatatable.new(view_context)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: usertable}
      format.csv do 
        if params[:all]
          render_csv("users.csv", usertable)
        else
          render text: usertable.as_csv
        end
      end
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
    @user.walking_speed_id = usr[:walking_speed_id]
    @user.walking_maximum_distance_id = usr[:walking_maximum_distance_id]

    respond_to do |format|
      if @user.save
        usr[:roles].reject(&:blank?).each { |id| @user.add_role( Role.find(id).name.to_sym ) }
        @user.add_role :registered_traveler
        if current_user.agency # create agency user relationship if current user is agency staff
          @agency_user_relationship = AgencyUserRelationship.new  #defaults to Status = 3, i.e. Active
          @agency_user_relationship.user = @user # @user should have been guarded above by @user.valid?, assume it exists
          @agency_user_relationship.agency = current_user.agency
          @agency_user_relationship.creator = current_user.id

          if @agency_user_relationship.save
            UserMailer.agency_helping_email(@agency_user_relationship.user.email, @agency_user_relationship.user.email, current_user.agency).deliver
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

    # prep for password validation in @user.update by removing the keys if neither one is set.  Otherwise, we want to catch with password validation in User.rb
    if params[:user][:password].blank? and params[:user][:password_confirmation].blank?
      params[:user].except! :password, :password_confirmation
    end

    if @user.update(user_params_with_password) # .update is a Devise method, not the standard update_attributes from Rails
      params[:user][:roles].reject(&:blank?).empty? ? @user.remove_role(:system_administrator) : @user.add_role(:system_administrator)
      @user_characteristics_proxy.update_maps(params[:user_characteristics_proxy])
      set_approved_agencies(params[:user][:approved_agency_ids])
      booking_alert = set_booking_services(@user, params[:user_service])
      @user.update_relationships(params[:user][:relationship])
      @user.add_buddies(params[:new_buddies])
      if booking_alert
        redirect_to admin_user_path(@user), :alert => "Invalid Client Id or Date of Birth."
      else
        redirect_to admin_user_path(@user, locale: current_user.preferred_locale), :notice => "User updated."
      end


    else
      render 'edit', :alert => "Unable to update user."
    end
  end

  def destroy
    @user.soft_delete
    flash[:notice] = t(:user_deleted)
    respond_to do |format|
      format.html { redirect_to admin_users_path }
      format.json { head :no_content }
    end
  end

  def undelete
    user = User.find(params[:id])
    user.undelete
    respond_to do |format|
      format.html { redirect_to admin_user_path(user) }
      format.json { head :no_content }
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

  def find_by_email
    user = User.staff_assignable.where("lower(email) = ?", params[:email].downcase).first #case insensitive
    traveler = User.find(params[:user_id])
    if user.nil?
      success = false
      msg = I18n.t(:no_user_with_email_address, email: params[:email]) # did you know that this was an XSS vector?  OOPS
    elsif user.eql? traveler
      success = false
      msg = t(:you_can_t_be_your_own_buddy)
    elsif traveler.pending_and_confirmed_delegates.include? user
      success = false
      msg = t(:you_ve_already_asked_them_to_be_a_buddy)
    else
      success = true
      msg = t(:please_save_buddies, name: user.first_name)
      output = user.email
      row = [
              user.name,
              user.email,
              I18n.t('relationship_status.relationship_status_pending'),
              UserRelationshipDecorator.decorate(UserRelationship.find_by(traveler: user, delegate: traveler)).buttons
            ]
    end
    respond_to do |format|
      format.js { render json: {output: output, msg: msg, success: success, user_id: user.try(:id), row: row} }
    end
  end

  private

  def user_params_with_password
    params.require(:user).permit(:first_name, :last_name, :email, :preferred_locale, :password, :password_confirmation, :walking_speed_id, :walking_maximum_distance_id, :preferred_mode_ids => [])
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
      UserMailer.agency_helping_email(@user.email, agency.email, agency)
    end
    revoked_agencies.each do |revoked_id|
      revoked = AgencyUserRelationship.find_by(agency_id: revoked_id, user_id: @user.id)
      revoked.update_attributes(relationship_status: RelationshipStatus.revoked)
    end
  end

  def set_booking_services(user, services)
    alert = false
    dob = services['dob']
    services.each do |id, user_id|
      unless id == 'dob'
        service = Service.find(id)

        eh = EcolaneHelpers.new
        unless user_id == ""
          unless eh.validate_passenger(user_id, dob)[0]
            alert = true
            next
          end
          user_service = UserService.where(user_profile: user.user_profile, service: service).first_or_initialize
          user_service.external_user_id = user_id
          user_service.save
        else
          user_services = UserService.where(user_profile: user.user_profile, service: service)
          user_services.each do |user_service|
            user_service.destroy
          end
        end
      end
    end
    alert
  end

  def render_csv(file_name, usertable)
    set_file_headers file_name
    set_streaming_headers

    response.status = 200

    #setting the body to an enumerator, rails will iterate this enumerator
    self.response_body = csv_lines(usertable)
  end


  def set_file_headers(file_name)
    headers["Content-Type"] = "text/csv"
    headers["Content-disposition"] = "attachment; filename=\"#{file_name}\""
  end


  def set_streaming_headers
    #nginx doc: Setting this to "no" will allow unbuffered responses suitable for Comet and HTTP streaming applications
    headers['X-Accel-Buffering'] = 'no'

    headers["Cache-Control"] ||= "no-cache"
    headers.delete("Content-Length")
  end

  def csv_lines(usertable)
    Enumerator.new do |y|
      usertable.as_csv_all(y)
    end

  end
end
