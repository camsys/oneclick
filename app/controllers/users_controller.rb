class UsersController < ApplicationController
  before_filter :authenticate_user!, :except => :initial_booking
  load_and_authorize_resource except: [:edit, :assist]

  def index
    authorize! :index, User, :message => t(:not_authorized_as_an_administrator)
    @users = User.all
  end

  def show
    @user_characteristics_proxy = UserCharacteristicsProxy.new(@user)
    @user_programs_proxy = UserProgramsProxy.new(@user)
    @user_accommodations_proxy = UserAccommodationsProxy.new(@user)
    @user = User.find(params[:id])
  end

  def update
    @user_characteristics_proxy = UserCharacteristicsProxy.new(User.find(@user)) #we inflate a new proxy every time, but it's transient, just holds a bunch of characteristics

    # prep for password validation in @user.update by removing the keys if neither one is set.  Otherwise, we want to catch with password validation in User.rb
    if params[:user][:password].blank? and params[:user][:password_confirmation].blank?
      params[:user].except! :password, :password_confirmation
    end

    if @user.update(user_params_with_password) and # .update is a Devise method, not the standard update_attributes from Rails
        @user_characteristics_proxy.update_maps(params[:user_characteristics_proxy])
      set_approved_agencies(params[:user][:approved_agency_ids])
      booking_alert = set_booking_services(@user, params[:user_service])
      
      unless params[:user][:relationship].nil?

        comparison_hash = {}

        params[:user][:relationship].keys.each do |key|
          id = key.to_i
          relationship_status = UserRelationship.where(id: id)[0].relationship_status_id.to_s
          comparison_hash[id.to_s] = relationship_status
        end

        if params[:user][:relationship] != comparison_hash

          params[:user][:relationship].each do |key, value|
            id = key.to_i
            relationship_value = value
            to_email = User.where(id: UserRelationship.where(id: id)[0].user_id)[0].email
            from_email = User.where(id: UserRelationship.where(id: id)[0].delegate_id)[0].email

            unless UserRelationship.where(id: id)[0].relationship_status_id == value.to_i
              # if the request is accepted
              if relationship_value == "3"
                UserMailer.traveler_confirmation_email(to_email, from_email).deliver
              # if the request is declined
              elsif relationship_value == "4"
                UserMailer.traveler_decline_email(to_email, from_email).deliver
              # either person revokes buddyship
              elsif relationship_value == "5"
                to_email = User.where(id: UserRelationship.where(id: id)[0].user_id)[0].email
                if @user.id == User.where(id: UserRelationship.where(id: id)[0].delegate_id)[0].id
                  # Requested revokes
                  UserMailer.buddy_revoke_email(to_email, from_email).deliver
                else
                  # Requester revokes
                  UserMailer.traveler_revoke_email(from_email, to_email).deliver
                end
              end
            end
          end
        end
      end

      # as the requested, got a request, accepting/rejecting, adding traveler_relationship
      @user.update_relationships(params[:user][:relationship])
      # as the requester, add buddy
      @user.add_buddies(params[:new_buddies])

      if booking_alert
        redirect_to user_path(@user, locale: @user.preferred_locale), :alert => "Invalid Client Id or Date of Birth."
      else
        if params[:user][:password] and params[:user][:password].eql? params[:user][:password_confirmation] # They have updated their password, so log them back in, otherwise they will fail authentication
          sign_in @user, :bypass => true
        end
        redirect_to user_path(@user, locale: @user.preferred_locale), :notice => "User updated."
      end
      #Add Traveler Notes
      if current_user.agency
        note = TravelerNote.where(user: @user, agency: current_user.agency).first_or_create
        note.note = params[:traveler_note][:note]
        note.save
      end


    else
      # if @user_characteristics_proxy has errors,
      # add base error to user to generate alert at top of form
      if @user_characteristics_proxy.errors.size > 0
        @user.errors.add(:base, '')
      end

      render 'edit'
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
    @user_characteristics_proxy = UserCharacteristicsProxy.new(@user)
  end


  def initial_booking
    #TODO: This is not DRY, It reuses a lot of what is in add_booking_service
    get_traveler
    external_user_id = params['user_service_proxy']['external_user_id']
    service = Service.find(params['user_service_proxy']['service_id'])
    @errors = false

    @booking_proxy = UserServiceProxy.new(external_user_id: external_user_id, service: service)

    #Check that the formatting is correct
    begin
      Date.strptime(params['user_service_proxy']['dob'], "%m/%d/%Y")
      dob = params['user_service_proxy']['dob']
    rescue ArgumentError
      @booking_proxy.errors.add(:dob, "Date needs to be in mm/dd/yyyy format.")
      @errors = true
    end

    #If the formatting is correct, check to see if this is a valid user
    unless @errors
      eh = EcolaneHelpers.new
      result, first_name, last_name = eh.validate_passenger(external_user_id, dob)
      unless result
        @booking_proxy.errors.add(:external_user_id, "Unknown Client Id or incorrect date of birth.")
        @errors = true
      end
    end

    #If everything checks out, create a link between the OneClick user and the Booking Service
    unless @errors
      #Todo: This will need to be updated when more services are able to book.
      if @traveler.is_visitor?
        @traveler = get_ecolane_traveler(external_user_id, dob, first_name, last_name)
      end
      Service.where(booking_service_code: 'ecolane').each do |booking_service|
        user_service = UserService.where(user_profile: @traveler.user_profile, service: booking_service).first_or_initialize
        user_service.external_user_id = external_user_id
        user_service.save
      end
    end

    #redirect_to new_user_trip_path(@traveler)
    #return

    @trip = Trip.last
    respond_to do |format|
      format.json {}
      format.js { render "trips/update_initial_booking" }
    end

  end

  def get_ecolane_traveler(external_user_id, dob, first_name, last_name)

    user_service = UserService.where(external_user_id: external_user_id).order('created_at').last
    if user_service
      u = user_service.user_profile.user
    else
      u = User.where(email: external_user_id + '@example.com').first_or_create
      u.first_name = first_name
      u.last_name = last_name
      u.password = dob
      u.password_confirmation = dob
      u.roles << Role.where(name: "registered_traveler").first
      up = UserProfile.new
      up.user = u
      up.save!
      result = u.save

      #Update Birth Year
      dob_object = Characteristic.where(code: "date_of_birth").first
      if dob_object
        user_characteristic = UserCharacteristic.where(characteristic_id: dob_object.id, user_profile: u.user_profile).first_or_initialize
        user_characteristic.value = dob.split('/')[2]
        user_characteristic.save
      end
    end

    sign_in u, :bypass => true
    u
  end


  def add_booking_service
    get_traveler
    external_user_id = params['user_service_proxy']['external_user_id']
    service = Service.find(params['user_service_proxy']['service_id'])
    itinerary = Itinerary.find(params['user_service_proxy']['itinerary_id'])
    errors = false

    @booking_proxy = UserServiceProxy.new(external_user_id: external_user_id, service: service)
    begin
      Date.strptime(params['user_service_proxy']['dob'], "%m/%d/%Y")
      dob = params['user_service_proxy']['dob']
    rescue ArgumentError
      @booking_proxy.errors.add(:dob, "Date needs to be in mm/dd/yyyy format.")
      errors = true
    end

    @trip = itinerary.trip_part.trip

    unless errors
      eh = EcolaneHelpers.new
      unless eh.validate_passenger(external_user_id, dob)[0]
        @booking_proxy.errors.add(:external_user_id, "Unknown Client Id or incorrect date of birth.")
        errors = true
      end
    end

    unless errors
      itinerary.is_bookable = true
      itinerary.save
      #Todo: This will need to be updated when more services are able to book.
      Service.where(booking_service_code: 'ecolane').each do |booking_service|
        user_service = UserService.where(user_profile: @traveler.user_profile, service: booking_service).first_or_initialize
        user_service.customer_id = nil
        user_service.external_user_id = external_user_id
        user_service.save
      end
    end

    respond_to do |format|
      format.json {}
      format.js { render "trips/update_booking" }
    end
  end

  def find_by_email
    #user = User.find_by(email: params[:email])
    user = User.staff_assignable.find(:first, :conditions => ["lower(email) = ?", params[:email].downcase]) #case insensitive
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
    @user = User.find(params[:id])
    authorize! :assist, User.find(params[:buddy_id])

    if UserRelationship.find_by(user_id: params[:buddy_id], delegate_id: @user)
      set_traveler_id params[:buddy_id]
      flash[:notice] = t(:assisting_turned_on)
      redirect_to new_user_trip_path(params[:buddy_id])
    end
  end

private

  def user_params_with_password
    params.require(:user).permit(:first_name, :last_name, :email, :preferred_locale, 
      :password, :password_confirmation, :walking_speed_id, :walking_maximum_distance_id, :maximum_wait_time,
      :title, :phone, :preferred_mode_ids => [])
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

        user_service = UserService.where(user_profile: user.user_profile, service: service).first_or_initialize
        #only validate on a change
        if user_service.external_user_id == user_id
          next
        end

        eh = EcolaneHelpers.new
        unless user_id == ""
          unless eh.validate_passenger(user_id, dob)[0]
            alert = true
            next
          end
          #user_service = UserService.where(user_profile: user.user_profile, service: service).first_or_initialize
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
