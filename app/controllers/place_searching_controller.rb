class PlaceSearchingController < TravelerAwareController

  # Include map helpers into this super class
  include MapHelper
  include TripsSupport

  # Search for addresses, existing addresses, or POIs based on text string entered by the user
  # def geocode

  #   # Populate the @traveler variable
  #   get_traveler

  #   @query = params[:query]
  #   @target = params[:target]

  #   if @target == "0"
  #     icon_base = 'startCandidate'
  #     key_base = 'start_candidate'
  #     cache_key = CACHED_FROM_ADDRESSES_KEY
  #   elsif @target == "1"
  #     icon_base = 'stopCandidate'
  #     key_base = 'stop_candidate'
  #     cache_key = CACHED_TO_ADDRESSES_KEY
  #   else
  #     icon_base = "placeCandidate"
  #     key_base = 'place_candidate'
  #     cache_key = CACHED_PLACES_ADDRESSES_KEY
  #   end

  #   if ENV['FAKE_GEOCODING_RESULTS']
  #     geocoder = OneclickGeocoderFake.new
  #   else
  #     geocoder = OneclickGeocoder.new
  #     geocoder.geocode(@query)
  #     # cache the results
  #     cache_addresses(cache_key, geocoder.results)
  #   end

  #   Rails.logger.info "geocoder is #{geocoder.class}"

  #   # This array will hold the list of candidate places
  #   @matches = []
  #   # We create a unique index for mapping etc for each place we find. Limited to 26 candidates as there are no letters past 'Z'
  #   # TODO Limit to 20 results for now; more than 20 seems to blow up something in the Javascript; see https://www.pivotaltracker.com/story/show/62266768

  #   geocoder.results.first(20).each_with_index do |addr, index|
  #     Rails.logger.debug "In geocoder.results.each_with_index loop, index #{index} addr #{addr}"
  #     icon_style = icon_base + MapHelper::ALPHABET[index]
  #     key = key_base + index.to_s
  #     @matches << get_addr_marker(addr, key, icon_style) unless index > 25
  #   end

  #   respond_to do |format|
  #     format.js { render "show_geocoding_results" }
  #     format.json { render :json => @matches, :status => :created, :location => @matches }
  #   end
  # end

  # Search for addresses, existing addresses, or POIs based on text string entered by the user
  def search
    Rails.logger.info "PlaceSearchingController#search"
    Rails.logger.info params.ai
    # Populate the @traveler variable
    get_traveler

    query = params[:query]
    query_str = query + "%"
    Rails.logger.info "query_str: #{query_str}"

    no_map_partial = params[:no_map_partial].to_bool

    matches = []
    counter = 0

    # First search for matching names in my places
    rel = Place.arel_table[:name].matches(query_str)
    places = @traveler.places.active.where(rel)
    places.each do |place|
      m = {
        "index" => counter,
        "type" => PLACES_TYPE,
        "type_name" => 'PLACES_TYPE',
        "name" => place.name,
        "id" => place.id,
        "lat" => place.location.first,
        "lon" => place.location.last,
        "address" => place.address,
        "full_address" => place.address,
        "description" => map_partial(no_map_partial, { :place => {:icon => 'fa-building-o', :name => place.name, :address => place.address} })
      }
      matches <<  m.merge(place.interesting_attributes)
      counter += 1
    end

    # # Second search for matching address in trip_places. We manually filter these to find unique addresses
    # rel = TripPlace.arel_table[:raw_address].matches(query_str)
    # tps = @traveler.trip_places.where(rel).order("raw_address")
    # old_addr = ""
    # tps.each do |tp|
    #   if old_addr != tp.raw_address
    #     matches << {
    #       "index" => counter,
    #       "type" => CACHED_ADDRESS_TYPE,
    #       "type_name" => 'CACHED_ADDRESS_TYPE',
    #       "name" => tp.raw_address,
    #       "id" => tp.id,
    #       "lat" => tp.lat,
    #       "lon" => tp.lon,
    #       "address" => tp.raw_address,
    #       "description" => map_partial(no_map_partial, { :place => {:icon => 'fa-building-o', :name => tp.name, :address => tp.raw_address} })
    #     }
    #     counter += 1
    #     old_addr = tp.raw_address
    #   end
    # end

    # Search for matching names in the POI table
    pois = Poi.get_by_query_str(query_str, MAX_POIS_FOR_SEARCH)
    pois.each do |poi|
      m = {
        "index" => counter,
        "type" => POI_TYPE,
        "type_name" => 'POI_TYPE',
        "description" => map_partial(no_map_partial, { :place => {:icon => 'fa-building-o', :name => poi.name,
          :address => poi.address} }),
        "full_address" => poi.get_address
      }
      matches <<  m.merge(poi.interesting_attributes)
      counter += 1
    end

    # do places search

    # puts "Oneclick::Application.config.google_place_search #{Oneclick::Application.config.google_place_search}"
    # case Oneclick::Application.config.google_place_search
    # when 'places'
      places_matches = do_google_place_search(query, params[:map_center], counter, no_map_partial)
    # when 'geocode'
    #   places_matches = do_google_geocode_search(query, params[:map_center])
    # else
    #   raise "google_place_search config value of #{Oneclick::Application.config.google_place_search} is unsupported"
    # end

    matches += places_matches
    counter += places_matches.size

    Rails.logger.info "PlaceSearchingController#search - returning #{matches.size} results for #{query_str}"
    render :json => matches.to_json
  end

def search_my
    Rails.logger.info "PlaceSearchingController#search_my"
    Rails.logger.info params.ai
    # Populate the @traveler variable
    get_traveler

    query = params[:query]
    query_str = query + "%"
    Rails.logger.info "query_str: #{query_str}"

    no_map_partial = params[:no_map_partial].to_bool

    matches = []
    counter = 0

    # First search for matching names in my places
    rel = Place.arel_table[:name].matches(query_str)
    places = @traveler.places.active.where(rel)
    places.each do |place|
      matches << {
        "index" => counter,
        "type" => PLACES_TYPE,
        "type_name" => 'PLACES_TYPE',
        "name" => place.name,
        "id" => place.id,
        "lat" => place.location.first,
        "lon" => place.location.last,
        "address" => place.address,
        "full_address" => place.address,
        "description" => map_partial(no_map_partial, { :place => {:icon => 'fa-building-o', :name => place.name, :address => place.address} })
      }
      counter += 1
    end

    Rails.logger.info "PlaceSearchingController#search_my - returning #{matches.size} results for #{query_str}"
    render :json => matches.to_json
  end

  def details
    result = get_places_autocomplete_details(params[:id])
    render json: result.body
  end

  protected

  def do_google_place_search query, map_center, counter, no_map_partial
    result = google_api.get('autocomplete/json') do |req|
      req.params['input']    = query
      req.params['sensor']   = false
      req.params['key']      = Oneclick::Application.config.google_places_api_key
      # req.params['key']      = 'AIzaSyBHlpj9FucwX45l2qUZ3441bkqvcxR8QDM'
      req.params['location'] = map_center
      req.params['radius']   = 20_000
    end
    
    Rails.logger.info result.status
    Rails.logger.info result.body.ai

    counter -= 1
    matches = result.body['predictions'].collect do |prediction|
      counter += 1
      {
        'index'   => counter,
        'type'    => PLACES_AUTOCOMPLETE_TYPE,
        'type_name'    => 'PLACES_AUTOCOMPLETE_TYPE',
        'name'    => prediction['description'],
        'id'      => prediction['reference'],
        'lat'     => nil,
        'lon'     => nil,
        'address' => prediction['description'],
        'description' => map_partial(no_map_partial, { place: {icon: 'icon-building', name: prediction['description'], address: prediction['description']} })
      }
    end
    matches
  end

  def do_google_geocode_search query, map_center
    g = OneclickGeocoder.new
    @results = g.geocode(query)
    @results
  end

  # Cache an array of addresses
  def cache_addresses(key, addresses, expires_in = ADDRESS_CACHE_EXPIRE_SECONDS)
    raise "Don't use cache_addresses any more"
    Rails.logger.info "PlaceSearchingController CACHE put for key #{get_cache_key(@traveler, key)}"
    Rails.cache.write(get_cache_key(@traveler, key), addresses, :expires_in => expires_in)
  end

  # Return an array of cached addresses
  def get_cached_addresses(key)
    raise "Don't use get_cache_addresses any more"
    Rails.logger.info "PlaceSearchingController CACHE get for key #{get_cache_key(@traveler, key)}"
    ret = Rails.cache.read(get_cache_key(@traveler, key))
    return ret.nil? ? [] : ret
  end

  # generates a cache key that is unique for a user and key name
  def get_cache_key(user, key)
    return "%06d:%s" % [user.id, key]
  end

  private

  def map_partial no_map_partial = true, locals = {}
    unless no_map_partial
      render_to_string(:partial => "/shared/map_popup", :locals => locals)
    else
      '(not rendered)'
    end
  end

end
