class UsersController < ApplicationController
  load_and_authorize_resource except: :edit
  before_filter :authenticate_user!

  def index
    authorize! :index, User, :message => t(:not_authorized_as_an_administrator)
    @users = User.all
  end

  def show
    authorize! :show, @user
    @user_characteristics_proxy = UserCharacteristicsProxy.new(@user)
    @user_programs_proxy = UserProgramsProxy.new(@user)
    @user_accommodations_proxy = UserAccommodationsProxy.new(@user)
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
    @user_characteristics_proxy = UserCharacteristicsProxy.new(User.find(@user)) #we inflate a new proxy every time, but it's transient, just holds a bunch of characteristics
    
    # Getting around devise- since password can't be blank, don't try to update it if they didn't pass it
    update_method = params[:password].blank? ? user_params_without_password : user_params_with_password
    if @user.update_attributes(update_method)
      @user_characteristics_proxy.update_maps(params[:user_characteristics_proxy])
      set_approved_agencies(params[:user][:approved_agency_ids])
      booking_alert = set_booking_services(@user, params[:user_service])
      @user.update_relationships(params[:user][:relationship])
      @user.add_buddies(params[:new_buddies])
      if booking_alert
        redirect_to user_path(@user, locale: @user.preferred_locale), :alert => "Invalid Client Id or Date of Birth."
      else
        redirect_to user_path(@user, locale: @user.preferred_locale), :notice => "User updated."
      end
    else
      redirect_to edit_user_path(@user), :alert => "Unable to update user."
    end
  end
    
  def destroy
    authorize! :destroy, @user, :message => t(:not_authorized_as_an_administrator)
    user = User.find(params[:id])
    unless user == current_user
      user.destroy
      redirect_to user_path, :notice => "User deleted."
    else
      redirect_to user_path, :notice => "Can't delete yourself."
    end
  end

  def edit
    # set_traveler_id params[:id] || current_user
    @user = User.includes(:traveler_relationships, :delegate_relationships).find(params[:id])
    authorize! :edit, @user
  end

  def add_booking_service
    get_traveler
    external_user_id = params['user_service_proxy']['external_user_id']
    service = Service.find(params['user_service_proxy']['service_id'])
    itinerary = Itinerary.find(params['user_service_proxy']['itinerary_id'])
    errors = false

    @booking_proxy = UserServiceProxy.new(external_user_id: external_user_id, service: service)
    begin
      dob = Date.strptime(params['user_service_proxy']['dob'], "%m/%d/%Y")
    rescue ArgumentError
      @booking_proxy.errors.add(:dob, "Date needs to be in mm/dd/yyyy format.")
      errors = true
    end

    eh = EcolaneHelpers.new
    unless eh.confirm_passenger(external_user_id, dob)
      @booking_proxy.errors.add(:external_user_id, "Unknown Client Id or incorrect date of birth.")
      errors = true
    end

    @trip = itinerary.trip_part.trip

    unless errors
      itinerary.is_bookable = true
      itinerary.save
      user_service = UserService.where(user_profile: @traveler.user_profile, service: service).first_or_initialize
      user_service.external_user_id = external_user_id
      user_service.save
    end

    #TODO:  Automatically add other rabbit transit services
    respond_to do |format|
      format.json {}
      format.js { render "trips/update_booking" }
    end
  end

  def find_by_email
    user = User.find_by(email: params[:email])
    traveler = User.find(params[:id])
    
    if user.nil?
      success = false
      msg = I18n.t(:no_user_with_email_address, email: ERB::Util.html_escape(params[:email])) # did you know that this was an XSS vector?  OOPS
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

  def assist
    # Confirm buddies
    ur = UserRelationship.find_by(user_id: params[:buddy_id], delegate_id: @user)
    if ur && ur.confirmed
      set_traveler_id params[:buddy_id]
      redirect_to new_user_trip_path(params[:buddy_id])
    else
      redirect_to user_path(@user), alert: t(:unauthorized)
    end
    
  end

private

  def user_params_without_password
    params.require(:user).permit(:first_name, :last_name, :email, :preferred_locale, :preferred_mode_ids => [])
  end

  def user_params_with_password
    params.require(:user).permit(:first_name, :last_name, :email, :preferred_locale, :password, :password_confirmation, :preferred_mode_ids => [])
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
          unless eh.confirm_passenger(user_id, dob)
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
end
