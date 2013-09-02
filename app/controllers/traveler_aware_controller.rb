class TravelerAwareController < ApplicationController
    
  # include the helper method in any controller which needs to know about guest users
  helper_method :current_or_guest_user
    
  # set the @traveler variable before any actions are invoked
  before_filter :get_traveler, :only => [:index, :new, :create, :show]

  # Session key for storing the traveler id
  TRAVELER_USER_SESSION_KEY = 'traveler'
  
  # Constants for type of place user has selected  
  POI_TYPE = "1"
  CACHED_ADDRESS_TYPE = "2"
  PLACES_TYPE = "3"
  RAW_ADDRESS_TYPE = "4"
  
protected

  # Update the session variable
  def set_traveler_id(id)
    session[TRAVELER_USER_SESSION_KEY] = id
  end
  
  # Sets the #traveler class variable
  def get_traveler

    if user_signed_in?
      if session[TRAVELER_USER_SESSION_KEY].blank?
        @traveler = current_user
      else
        @traveler = current_user.travelers.find(session[TRAVELER_USER_SESSION_KEY])
      end 
    else
      # will always be a guest user
      @traveler = current_or_guest_user
    end
  end

end
