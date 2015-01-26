# trip support singleton and mixin
module TripsSupport
  TIME_FILTER_TYPE_SESSION_KEY = 'trips_time_filter_type'

  # Format strings for the trip form date and time fields
  TRIP_DATE_FORMAT_STRING = "%m/%d/%Y"
  TRIP_TIME_FORMAT_STRING = "%-I:%M %P"

  # Set up configurable defaults
  DEFAULT_RETURN_TRIP_DELAY_MINS = Rails.application.config.return_trip_delay_mins
  DEFAULT_TRIP_TIME_AHEAD_MINS   = Rails.application.config.trip_time_ahead_mins
  DEFAULT_OUTBOUND_TRIP_AHEAD_MINS = Rails.application.config.default_trip_ahead_mins

  # Modes for creating/updating new trips
  MODE_NEW    = "1" # Its a new trip from scratch
  MODE_EDIT   = "2" # Editing an existing trip that is in the future
  MODE_REPEAT = "3" # Repeating an existing trip that is in the past

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
  PLACES_AUTOCOMPLETE_TYPE = '5'
  KIOSK_LOCATION_TYPE = '6'

  # Set the default travel time/date to x mins from now
  # def default_trip_time
  #   Time.now.in_time_zone.next_interval(DEFAULT_TRIP_TIME_AHEAD_MINS.minutes)
  # end

  def get_trip_place(place_id)
    if can? :manage, :all
      begin
        @trip_place = TripPlace.find(place_id)
      rescue => ex
        Rails.logger.debug ex.message
        @trip_place = nil
      end
    else
      begin
        @trip_place = @traveler.trip_places.find(place_id)
      rescue => ex
        Rails.logger.debug ex.message
        @trip_place = nil
      end
    end
  end

  # Safely set the @trip variable taking into account trip ownership
  def get_trip
    # limit trips to trips accessible by the user unless an admin
    if can? :manage, :all
      begin
        @trip = Trip.find(params[:id])
      rescue => ex
        Rails.logger.debug ex.message
        @trip = nil
      end
    else
      begin
        @trip = @traveler.trips.find(params[:id])
      rescue => ex
        Rails.logger.debug ex.message
        @trip = nil
      end
    end
  end

  # Get the selected place for this trip-end based on the type of place
  # selected and the data for that place
  def get_preselected_place(place_type, place_id, is_from = false)
    case place_type
    when POI_TYPE
      # the user selected a POI using the type-ahead function
      poi = Poi.find(place_id)
      return {
        :poi_id => poi.id,
        :name => poi.name,
        :formatted_address => poi.address,
        :lat => poi.location.first,
        :lon => poi.location.last
      }
    when CACHED_ADDRESS_TYPE
      # the user selected an address from the trip-places table using the type-ahead function
      trip_place = get_trip_place(place_id)
      return {
        :name => trip_place.raw_address,
        :lat => trip_place.lat,
        :lon => trip_place.lon,
        :formatted_address => trip_place.raw,
        :street_address => trip_place.address1,
        :city => trip_place.city,
        :state => trip_place.state,
        :zip => trip_place.zip,
        :county => trip_place.county,
        :raw => trip_place.raw
      }
    when PLACES_TYPE
      # the user selected a place using the places drop-down
      trip_place = @traveler.places.find(place_id)
      return {
        :place_id => trip_place.id,
        :name => trip_place.name,
        :formatted_address => trip_place.address,
        :lat => trip_place.location.first,
        :lon => trip_place.location.last
      }
    when RAW_ADDRESS_TYPE
      # the user entered a raw address and possibly selected an alternate from the list of possible
      # addresses

      # if is_from
      #   #puts place_id
      #   #puts get_cached_addresses(CACHED_FROM_ADDRESSES_KEY).ai
      #   place = get_cached_addresses(CACHED_FROM_ADDRESSES_KEY)[place_id.to_i]
      # else
      #   place = get_cached_addresses(CACHED_TO_ADDRESSES_KEY)[place_id.to_i]
      # end
      Rails.logger.info "in get_preselected_place"
      Rails.logger.info "#{is_from} #{place.ai}"
      return {
        :name => place[:name],
        :lat => place[:lat],
        :lon => place[:lon],
        :formatted_address => place[:formatted_address],
        :street_address => place[:street_address],
        :city => place[:city],
        :state => place[:state],
        :zip => place[:zip],
        :county => place[:county],
        :raw => place[:raw]
      }
    when PLACES_AUTOCOMPLETE_TYPE
      result = get_places_autocomplete_details(place_id)
      place = result.body['result']
      # puts "====== PLACES_AUTOCOMPLETE_TYPE ======"
      # puts place
      {
        place_id:          false,
        name:              place['formatted_address'],
        formatted_address: place['formatted_address'],
        lat:               place['geometry']['location']['lat'],
        lon:               place['geometry']['location']['lng'],
      }
    when KIOSK_LOCATION_TYPE
      place = KioskLocation.find(place_id)

      {
        name:              place[:name],
        formatted_address: place[:addr],
        lat:               place[:lat],
        lon:               place[:lon]
      }
    else
      raise "unhandled place type: #{place_type}"
    end
  end

  def get_places_autocomplete_details reference
    google_api.get('details/json') do |req|
      req.params['reference'] = reference
      req.params['sensor']    = true
      req.params['key']       = Oneclick::Application.config.google_places_api_key
      req.params['components'] = Oneclick::Application.config.geocoder_components
    end
  end

  def google_place_search query, map_center
    google_api.get('autocomplete/json') do |req|
      req.params['input']    = query
      req.params['sensor']   = false
      req.params['key']      = Oneclick::Application.config.google_places_api_key
      req.params['location'] = map_center
      req.params['radius']   = Oneclick::Application.config.google_radius_meters
      req.params['components'] = Oneclick::Application.config.geocoder_components
    end
  end

  def google_api
    connection = Faraday.new('https://maps.googleapis.com/maps/api/place') do |conn|
      # conn.response :mashify
      conn.response :json
      conn.adapter Faraday.default_adapter
    end
  end

  # This expects to be passed the result component, e.g. g.body['result']
  def cleanup_google_details detail_result
    components = detail_result['address_components']
    r = components.inject({}) do |m, c|
      m[determining_type(c['types'])] = c['short_name']
      m
    end
    r['address1'] = [r['street_number'], r['route']].join(' ')
    r['city'] = r['locality']
    r['zip'] = r['postal_code']
    r['county'] = r['administrative_area_level_2'].gsub(%r{ County$}, '') if r['administrative_area_level_2']
    r['state'] = r['administrative_area_level_1']
    r['lat'] = detail_result['geometry']['location']['lat']
    r['lon'] = detail_result['geometry']['location']['lng']
    r['result_types'] = (detail_result['types'] || []).join('|')
    r
  end

  extend self

  private

  def determining_type a
    (a.reject {|t| t=='political'}).first
  end
end

