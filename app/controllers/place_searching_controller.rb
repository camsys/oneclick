class PlaceSearchingController < TravelerAwareController
    
  # UI Constants  
  MAX_POIS_FOR_SEARCH = Rails.application.config.ui_search_poi_items
  ADDRESS_CACHE_EXPIRE_SECONDS = Rails.application.config.address_cache_expire_seconds

  # Cache keys
  CACHED_FROM_ADDRESSES_KEY = 'CACHED_FROM_ADDRESSES_KEY'
  CACHED_TO_ADDRESSES_KEY = 'CACHED_TO_ADDRESSES_KEY'
  CACHED_PLACES_ADDRESSES_KEY = 'CACHED_PLACES_ADDRESSES_KEY'

  ALPHABET = ('A'..'Z').to_a
  
  # Constants for type of place user has selected  
  POI_TYPE = "1"
  CACHED_ADDRESS_TYPE = "2"
  PLACES_TYPE = "3"
  RAW_ADDRESS_TYPE = "4"

  # Search for addresses, existing addresses, or POIs based on text string entered by the user
  def geocode
    
    Rails.logger.info "GEOCODE"

    # Populate the @traveler variable
    get_traveler
    
    @query = params[:query]
    @target = params[:target]
    
    if @target == "0"
      icon_base = 'startCandidate'
      key_base = 'start_candidate'
      cache_key = CACHED_FROM_ADDRESSES_KEY
    elsif @target == "1"
      icon_base = 'stopCandidate'
      key_base = 'stop_candidate'
      cache_key = CACHED_TO_ADDRESSES_KEY
    else
      icon_base = "placeCandidate"
      key_base = 'place_candidate'
      cache_key = CACHED_PLACES_ADDRESSES_KEY
    end
    Rails.logger.info @query

    geocoder = OneclickGeocoder.new
    geocoder.geocode(@query)
    # cache the results
    cache_addresses(cache_key, geocoder.results)

    # This array will hold the list of candidate places
    @matches = []    
    # We create a unique index for mapping etc for each place we find. Limited to 26 candidates as there are no letters past 'Z'
    geocoder.results.each_with_index do |addr, index|
      icon_style = icon_base + ALPHABET[index] 
      key = key_base + index.to_s
      @matches << get_addr_marker(addr, key, icon_style) unless index > 25
    end
    
    respond_to do |format|
      format.js { render "show_geocoding_results" }
      format.json { render :json => @matches, :status => :created, :location => @matches }
    end
  end
  
  # Search for addresses, existing addresses, or POIs based on text string entered by the user
  def search
    
    Rails.logger.info "SEARCH"

    # Populate the @traveler variable
    get_traveler
    
    query = params[:query]
    query_str = query + "%"
    Rails.logger.info query_str

    # This array will hold the list of matching places
    matches = []    
    # We create a unique index for mapping etc for each place we find
    counter = 0    
    
    # First search for matching names in my places
    rel = Place.arel_table[:name].matches(query_str)
    places = @traveler.places.active.where(rel)
    Rails.logger.info places.ai
    places.each do |place|
      matches << {
        "index" => counter,
        "type" => PLACES_TYPE,
        "name" => place.name,
        "id" => place.id,
        "lat" => place.location.first,
        "lon" => place.location.last,
        "address" => place.address,
        "description" => render_to_string(:partial => "/shared/map_popup", :locals => { :place => {:icon => 'icon-building', :name => place.name, :address => place.address} })
      }
      counter += 1
    end
    
    # Second search for matching address in trip_places. We manually filter these to find unique addresses
    rel = TripPlace.arel_table[:raw_address].matches(query_str)
    tps = @traveler.trip_places.where(rel).order("raw_address")
    Rails.logger.info tps.ai
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
          "address" => tp.raw_address,
          "description" => render_to_string(:partial => "/shared/map_popup", :locals => { :place => {:icon => 'icon-building', :name => tp.name, :address => tp.raw_address} })
        }
        counter += 1
        old_addr = tp.raw_address
      end      
    end
    
    # Lastly search for matching names in the POI table
    rel = Poi.arel_table[:name].matches(query_str)
    pois = Poi.where(rel).limit(MAX_POIS_FOR_SEARCH)
    Rails.logger.info pois.ai
    pois.each do |poi|
      matches << {
        "index" => counter,
        "type" => POI_TYPE,
        "name" => poi.name,
        "id" => poi.id,
        "lat" => poi.lat,
        "lon" => poi.lon,
        "address" => poi.address,
        "description" => render_to_string(:partial => "/shared/map_popup", :locals => { :place => {:icon => 'icon-building', :name => poi.name, :address => poi.address} })
      }
      counter += 1
    end
    
    respond_to do |format|
      format.js { render :json => matches.to_json }
      format.json { render :json => matches.to_json }
    end
  end
  
protected

  def get_indexed_marker_icon(index, type)
    if type == "0"
      return 'startCandidate' + ALPHABET[index]
    elsif type == "1"
      return 'stopCandidate' + ALPHABET[index]
    else
      return 'placeCandidate' + ALPHABET[index]
    end
  end
  
  # Cache an array of addresses
  def cache_addresses(key, addresses, expires_in = ADDRESS_CACHE_EXPIRE_SECONDS)
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
  
end
