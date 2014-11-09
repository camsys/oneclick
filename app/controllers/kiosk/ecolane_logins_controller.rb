class Kiosk::EcolaneLoginsController < Kiosk::TripsController
  skip_before_filter :authenticate_user!
  skip_load_and_authorize_resource

  def show
    redirect_to '/' if params[:back]
    @booking_proxy = UserServiceProxy.new    
  end

  # copied and pasted from UsersController#initial_booking
  def create
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
      flash[:error] = "Date needs to be in mm/dd/yyyy format."
      @errors = true
    end

    #If the formatting is correct, check to see if this is a valid user
    unless @errors
      eh = EcolaneHelpers.new
      result, first_name, last_name = eh.validate_passenger(external_user_id, dob)

      unless result
        flash[:error] = "Unknown Client Id or incorrect date of birth."
        @errors = true
      end
    end

    if @errors
      render :show
    else
      # If everything checks out, create a link between the OneClick user and the Booking Service
      # TODO This will need to be updated when more services are able to book.
      if @traveler.is_visitor?
        @traveler = get_ecolane_traveler(external_user_id, dob, first_name, last_name)
      end

      Service.where(booking_service_code: 'ecolane').each do |booking_service|
        user_service = UserService.where(user_profile: @traveler.user_profile, service: booking_service).first_or_initialize
        user_service.external_user_id = external_user_id
        user_service.save
      end

      redirect_to kiosk_user_new_trip_start_path(@traveler)
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
      up = UserProfile.new
      up.user = u
      up.save!
      result = u.save
    end

    sign_in u, :bypass => true
    u
  end
end
