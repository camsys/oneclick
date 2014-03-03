class PlaceSearchingController < TravelerAwareController

  # Include map helpers into this super class
  include MapHelper

  # UI Constants  
  MAX_POIS_FOR_SEARCH = Rails.application.config.ui_search_poi_items
  ADDRESS_CACHE_EXPIRE_SECONDS = Rails.application.config.address_cache_expire_seconds

  # Cache keys
  CACHED_FROM_ADDRESSES_KEY = 'CACHED_FROM_ADDRESSES_KEY'
  CACHED_TO_ADDRESSES_KEY = 'CACHED_TO_ADDRESSES_KEY'
  CACHED_PLACES_ADDRESSES_KEY = 'CACHED_PLACES_ADDRESSES_KEY'

  # Constants for type of place user has selected  
  POI_TYPE = "1"
  CACHED_ADDRESS_TYPE = "2"
  PLACES_TYPE = "3"
  RAW_ADDRESS_TYPE = "4"

  # Search for addresses, existing addresses, or POIs based on text string entered by the user
  def geocode

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

    unless ENV['FAKE_GEOCODING_RESULTS']
      geocoder = OneclickGeocoder.new
      geocoder.geocode(@query)
      # cache the results
      cache_addresses(cache_key, geocoder.results)
    else
      geocoder = OneclickGeocoderFake.new
    end

    Rails.logger.info "geocoder is #{geocoder.class}"

    # This array will hold the list of candidate places
    @matches = []    
    # We create a unique index for mapping etc for each place we find. Limited to 26 candidates as there are no letters past 'Z'
    # TODO Limit to 20 results for now; more than 20 seems to blow up something in the Javascript; see https://www.pivotaltracker.com/story/show/62266768
    geocoder.results.first(20).each_with_index do |addr, index|
      Rails.logger.debug "In geocoder.results.each_with_index loop, index #{index} addr #{addr}"
      icon_style = icon_base + MapHelper::ALPHABET[index] 
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

    # Populate the @traveler variable
    get_traveler
    
    query = params[:query]
    query_str = query + "%"
    Rails.logger.debug query_str

    # This array will hold the list of matching places
    matches = []    
    # We create a unique index for mapping etc for each place we find
    counter = 0    
    
    # First search for matching names in my places
    rel = Place.arel_table[:name].matches(query_str)
    places = @traveler.places.active.where(rel)
    places.each do |place|
      matches << {
        "index" => counter,
        "type" => PLACES_TYPE,
        "name" => place.name,
        "id" => place.id,
        "lat" => place.location.first,
        "lon" => place.location.last,
        "address" => place.address,
        "description" => render_to_string(:partial => "/shared/map_popup", :locals => { :place => {:icon => 'fa-building-o', :name => place.name, :address => place.address} })
      }
      counter += 1
    end
    
    # Second search for matching address in trip_places. We manually filter these to find unique addresses
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
          "address" => tp.raw_address,
          "description" => render_to_string(:partial => "/shared/map_popup", :locals => { :place => {:icon => 'fa-building-o', :name => tp.name, :address => tp.raw_address} })
        }
        counter += 1
        old_addr = tp.raw_address
      end      
    end
    
    # Lastly search for matching names in the POI table
    rel = Poi.arel_table[:name].matches(query_str)
    pois = Poi.where(rel).limit(MAX_POIS_FOR_SEARCH)
    pois.each do |poi|
      matches << {
        "index" => counter,
        "type" => POI_TYPE,
        "name" => poi.name,
        "id" => poi.id,
        "lat" => poi.lat,
        "lon" => poi.lon,
        "address" => poi.address,
        "description" => render_to_string(:partial => "/shared/map_popup", :locals => { :place => {:icon => 'fa-building-o', :name => poi.name, :address => poi.address} })
      }
      counter += 1
    end
    
    respond_to do |format|
      format.js { render :json => matches.to_json }
      format.json { render :json => matches.to_json }
    end
  end
  
  protected
  
  # Cache an array of addresses
  def cache_addresses(key, addresses, expires_in = ADDRESS_CACHE_EXPIRE_SECONDS)
    Rails.logger.info "PlaceSearchingController CACHE put for key #{get_cache_key(@traveler, key)}"
    Rails.cache.write(get_cache_key(@traveler, key), addresses, :expires_in => expires_in)
  end
  
  # Return an array of cached addresses
  def get_cached_addresses(key)
    Rails.logger.info "PlaceSearchingController CACHE get for key #{get_cache_key(@traveler, key)}"
    ret = Rails.cache.read(get_cache_key(@traveler, key))
    return ret.nil? ? [] : ret
  end

  # generates a cache key that is unique for a user and key name
  def get_cache_key(user, key)
    return "%06d:%s" % [user.id, key]
  end
  
end
