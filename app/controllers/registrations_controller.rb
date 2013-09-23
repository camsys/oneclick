# app/controllers/registrations_controller.rb
class RegistrationsController < Devise::RegistrationsController
  include LocaleHelpers
  before_filter :set_locale

  def new
    super
  end

  helper_method :current_or_guest_user
    
  # set the @traveler variable before any actions are invoked
  before_filter :get_traveler, :only => [:update, :edit]

  def create
    session[:location] = new_user_registration_path
    super
  end
  
  def update
    session[:location] = edit_user_registration_path
    super
  end

  def edit
    @user_relationship = UserRelationship.new
    @user_characteristics_proxy = UserCharacteristicsProxy.new(@traveler)

    #Add dob
    dob_characteristic = TravelerCharacteristic.find_by_code('date_of_birth')
    map = UserTravelerCharacteristicsMap.where(characteristic_id: dob_characteristic.id, user_profile_id: @user_characteristics_proxy.user.user_profile.id).first
    unless map.nil?
      begin
        temp_date = Date.parse(map.value)
      rescue
        @user_characteristics_proxy.dob_day = 'dd'
        @user_characteristics_proxy.dob_month = 'mm'
        @user_characteristics_proxy.dob_year = 'yyyy'
      else
        @user_characteristics_proxy.dob_day = temp_date.day
        @user_characteristics_proxy.dob_month = temp_date.month
        @user_characteristics_proxy.dob_year = temp_date.year
      end
    end

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