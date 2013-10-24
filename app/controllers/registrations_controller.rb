# app/controllers/registrations_controller.rb
class RegistrationsController < Devise::RegistrationsController
  include LocaleHelpers
  before_filter :set_locale
  # set the @traveler variable before any actions are invoked
  before_filter :get_traveler, :only => [:update, :edit]

  helper_method :current_or_guest_user
    

  def new

    if params['inline'] == '1'
      session[:inline] = 1
    else
      session[:inline] = nil
      session[:current_trip_id] = nil
    end

    setup_form
    super
  end


  def after_sign_in_path_for(resource)

    if session[:inline]
      get_traveler
      @planned_trip = PlannedTrip.find(session[:current_trip_id])
      session[:current_trip_id] =  nil
      @planned_trip.create_itineraries
      user_planned_trip_path(@traveler, @planned_trip)
    else
      root_path
    end
  end

  # Overrides the Devise create method for new registrations
  def create
    #puts ">>>>> IN CREATE"
    session[:location] = new_user_registration_path
    
    build_resource(sign_up_params)
    #puts "RESOURCE OBJ"
    #puts resource.inspect
    #puts "GUEST USER"
    #puts guest_user.inspect
    
    guest_user.first_name = resource.first_name
    guest_user.last_name = resource.last_name
    guest_user.email = resource.email
    guest_user.encrypted_password = resource.encrypted_password

    setup_form

    if resource.valid? and guest_user.save
      if guest_user.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_up(resource_name, guest_user)
        respond_with guest_user, :location => after_sign_up_path_for(guest_user)
      else
        set_flash_message :notice, :"signed_up_but_#{guest_user.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
        respond_with guest_user, :location => after_inactive_sign_up_path_for(guest_user)
      end
    else
      respond_with resource
    end
  end

  def setup_form

    if session[:inline]
      get_traveler
      @create_inline = true
      @planned_trip = PlannedTrip.find(session[:current_trip_id])
    else
      @create_inline = false
    end
  end

  def update
    session[:location] = edit_user_registration_path
    @user_relationship = UserRelationship.new
    @user_characteristics_proxy = UserCharacteristicsProxy.new(@traveler)
    @user_programs_proxy = UserProgramsProxy.new(@traveler)
    @user_accommodations_proxy = UserAccommodationsProxy.new(@traveler)
    super
  end

  def edit
    @user_relationship = UserRelationship.new
    @user_characteristics_proxy = UserCharacteristicsProxy.new(@traveler)
    @user_programs_proxy = UserProgramsProxy.new(@traveler)
    @user_accommodations_proxy = UserAccommodationsProxy.new(@traveler)
    super
  end

protected

  # Update the session variable
  def set_traveler_id(id)
    session[TravelerAwareController::TRAVELER_USER_SESSION_KEY] = id
  end

  # Sets the #traveler class variable
  def get_traveler

    if user_signed_in?
      if session[TravelerAwareController::TRAVELER_USER_SESSION_KEY].blank?
        @traveler = current_user
      else
        @traveler = current_user.travelers.find(session[TravelerAwareController::TRAVELER_USER_SESSION_KEY])
      end 
    else
      # will always be a guest user
      @traveler = current_or_guest_user
    end
  end

end 