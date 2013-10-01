class TravelerAwareController < ApplicationController
    
  # include the helper method in any controller which needs to know about guest users
  helper_method :current_or_guest_user
    
  # set the @traveler variable before any actions are invoked
  before_filter :get_traveler, :only => [:index, :new, :create, :show]

  # Session key for storing the traveler id
  TRAVELER_USER_SESSION_KEY = 'traveler'
  
protected
  
  # create a map marker for a place
  def get_map_marker(place, id, icon)
    {
      "id" => id,
      "lat" => place.location.first,
      "lng" => place.location.last,
      "name" => place.name,
      "iconClass" => icon,
      "title" => place.address,
      "description" => render_to_string(:partial => "/shared/map_popup", :locals => { :place => {:icon => 'icon-building', :name => place.name, :address => place.address} })
    }
  end
  # create a map marker for a geocoded address
  def get_addr_marker(addr, id, icon)
    address = addr[:formatted_address].nil? ? addr[:address] : addr[:formatted_address]
    {
      "id" => id,
      "lat" => addr[:lat],
      "lng" => addr[:lon],
      "name" => addr[:name],
      "iconClass" => icon,
      "title" =>  address,
      "description" => render_to_string(:partial => "/shared/map_popup", :locals => { :place => {:icon => 'icon-building', :name => addr[:name], :address => address} })
    }
  end
  
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
