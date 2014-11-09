# app/controllers/registrations_controller.rb
class RegistrationsController < Devise::RegistrationsController
  include LocaleHelpers
  before_filter :configure_permitted_parameters
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

  # Overrides the Devise create method for new registrations
  def create
    #puts ">>>>> IN CREATE"
    session[:location] = new_user_registration_path
    if Oneclick::Application.config.initial_signup_question
      session[:first_login] = true
    end
    build_resource(sign_up_params)
    puts "RESOURCE: #{resource.ai}"
    #puts "RESOURCE OBJ"
    #puts resource.inspect
    #puts "GUEST USER"
    #puts guest_user.inspect

    guest_user.first_name = resource.first_name
    guest_user.last_name = resource.last_name
    guest_user.email = resource.email
    guest_user.encrypted_password = resource.encrypted_password
    guest_user.preferred_locale = resource.preferred_locale
    
    setup_form
    if resource.valid? and guest_user.save
      guest_user.add_role :registered_traveler
      guest_user.revoke :anonymous_traveler
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

    @default_locale = params[:locale] || 'en'
    
    if session[:inline]
      get_traveler
      @create_inline = true
      @trip = Trip.find(session[:current_trip_id])
    else
      @create_inline = false
    end
  end

  def update
    session[:location] = edit_user_registration_path
    @agency_user_relationship = AgencyUserRelationship.new
    @user_relationship = UserRelationship.new
    @user_characteristics_proxy = UserCharacteristicsProxy.new(@traveler)
    @user_programs_proxy = UserProgramsProxy.new(@traveler)
    @user_accommodations_proxy = UserAccommodationsProxy.new(@traveler)
    @user = @traveler
    render 'edit'
  end

  def edit
    @agency_user_relationship = AgencyUserRelationship.new
    @user_relationship = UserRelationship.new
    @user_characteristics_proxy = UserCharacteristicsProxy.new(@traveler)
    @user_programs_proxy = UserProgramsProxy.new(@traveler)
    @user_accommodations_proxy = UserAccommodationsProxy.new(@traveler)
    @user = @traveler
    
    render 'edit'
  end

  protected
 
  # See https://gist.github.com/bluemont/e304e65e7e15d77d3cb9
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:first_name, :last_name,
        :email, :password, :password_confirmation, :approved_agencies, :preferred_locale, :walking_speed_id, :walking_maximum_distance_id)
    end
    devise_parameter_sanitizer.for(:account_update) do |u|
      u.permit(:first_name, :last_name,
        :email, :password, :password_confirmation, :approved_agencies, :preferred_locale, :current_password, :walking_speed_id, :walking_maximum_distance_id)
    end
  end

  def after_update_path_for(resource)
    edit_user_registration_path(locale: resource.preferred_locale)
  end
 
end
