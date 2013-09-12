class TravelerAwareController < ApplicationController
    
  # include the helper method in any controller which needs to know about guest users
  helper_method :current_or_guest_user
    
  # set the @traveler variable before any actions are invoked
  before_filter :get_traveler, :only => [:index, :new, :create, :show]

  # Session key for storing the traveler id
  TRAVELER_USER_SESSION_KEY = 'traveler'

  # UI Constants  
  MAX_POIS_FOR_SEARCH = Rails.application.config.ui_search_poi_items
  
  # Constants for type of place user has selected  
  POI_TYPE = "1"
  CACHED_ADDRESS_TYPE = "2"
  PLACES_TYPE = "3"
  RAW_ADDRESS_TYPE = "4"
  
  # Search for addresses, existing addresses, or POIs based on text string entered by the user
  def search
    
    Rails.logger.info "SEARCH"

    get_traveler
    
    query = params[:query]
    query_str = query + "%"
    
    counter = 0
    
    # First search for POIs
    # Need this to get correct case-insensitive search for postgresql without breaking mysql
    rel = Poi.arel_table[:name].matches(query_str)
    pois = Poi.where(rel).limit(MAX_POIS_FOR_SEARCH)
    Rails.logger.info pois.ai
    matches = []
    pois.each do |poi|
      matches << {
        "index" => counter,
        "type" => POI_TYPE,
        "name" => poi.name,
        "id" => poi.id,
        "lat" => poi.lat,
        "lon" => poi.lon,
        "address" => poi.address
      }
      counter += 1
    end
    
    # now search for existing trip ends. We manually filter these to find unique addresses
    rel = TripPlace.arel_table[:raw_address].matches(query_str)
    tps = @traveler.trip_places.where(rel).order("raw_address")
    old_addr = ""
    tps.each do |tp|
      if old_addr != tp.raw_address
        matches << {
          "index" => counter,
          "type" => CACHED_ADDRESS_TYPE,
          "name" => tp.raw_address,
          "id" => tp.id,
          "lat" => tp.lat,
          "lon" => tp.lon,
          "address" => tp.raw_address
        }
        counter += 1
        old_addr = tp.raw_address
      end      
    end
    respond_to do |format|
      format.js { render :json => matches.to_json }
    end
  end
  
protected

  # Cache an array of addresses
  def cache_addresses(key, addresses, expires_in = 500.seconds)
    Rails.cache.write(get_cache_key(@traveler, key), addresses, :expires_in => expires_in)
  end
  # Return an array of cached addresses
  def get_cached_addresses(key)
    ret = Rails.cache.read(get_cache_key(@traveler, key))
    return ret.nil? ? [] : ret
  end
    
  # generates a cache key that is unique for a user and key name
  def get_cache_key(user, key)
    return "%06d:%s" % [user.id, key]
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
