module MapHelper

  ALPHABET = ('A'..'Z').to_a

  unless ENV['UI_MODE']=='kiosk'
    POPUP_PARTIAL = "/shared/map_popup"
    BUILDING_ICON = 'fa-building-o'
  else
    POPUP_PARTIAL = "/shared/map_popup_b2"
    BUILDING_ICON = 'icon-building'
  end

  # Returns a formatted string for displaying a map marker image that includes a A,B,C, etc. designator.
  #
  # index is a positive integer x, x >= 0 that corresponds to the index of the object in
  # an abitarily ordered list
  #
  # type is an enumeration
  #   0 = a start candidate location
  #   1 = a stop candidate location
  #   2 = a place candidate
  def get_candidate_list_item_image(index, type)
    if type == "0"
      return 'http://maps.google.com/mapfiles/marker_green' + ALPHABET[index] + ".png"
    elsif type == "1"
      return 'http://maps.google.com/mapfiles/marker' + ALPHABET[index] + ".png"
    else
      return 'http://maps.google.com/mapfiles/marker_yellow' + ALPHABET[index] + ".png"
    end
  end

  # create a map marker for a place
  #
  # place is an instance of the Place class
  # id is a unique identifier for the place that could be a string
  # icon is a named icon from the leafletmap_icons.js file
  def get_map_marker(place, id, icon)
    {
      "id" => id,
      "lat" => place.location.first,
      "lng" => place.location.last,
      "name" => place.name,
      "iconClass" => icon,
      "title" => place.address,
      "description" => render_to_string(:partial => POPUP_PARTIAL, :locals => { :place => {:icon => BUILDING_ICON, :name => place.name, :address => place.address} })
    }
  end

  # create a map marker for a geocoded address
  #
  # addr is a hash returned from the OneClick Geocoder
  # id is a unique identifier for the place that could be a string
  # icon is a named icon from the leafletmap_icons.js file
  def get_addr_marker(addr, id, icon)
    address = addr[:formatted_address].nil? ? addr[:address] : addr[:formatted_address]
    {
      "id" => id,
      "lat" => addr[:lat],
      "lng" => addr[:lon],
      "name" => addr[:name],
      "iconClass" => icon,
      "title" =>  address,
      "description" => ApplicationController.new.render_to_string(:partial => POPUP_PARTIAL, :locals => { :place => {:icon => BUILDING_ICON, :name => addr[:name], :address => address} })
    }
  end

  # create a map marker for a leg start location
  #
  # addr is a hash returned from the OneClick Geocoder
  # id is a unique identifier for the place that could be a string
  # icon is a named icon from the leafletmap_icons.js file
  def get_leg_start_marker(addr, id, icon)
    address = addr[:formatted_address].nil? ? addr[:address] : addr[:formatted_address]
    {
      "id" => id,
      "lat" => addr[:lat],
      "lng" => addr[:lon],
      "name" => addr[:name],
      "iconClass" => icon,
      "title" =>  addr[:name], #only diff from get_addr_marker
      "description" => ApplicationController.new.render_to_string(:partial => "/shared/map_popup", :locals => { :place => {:icon => 'fa-building-o', :name => addr[:name], :address => address} })
    }
  end

  # create an array of map markers for a collection of Place objects
  def create_place_markers(places)
    markers = []
    places.each do |place|
      markers << get_map_marker(place, place.id, 'startIcon')
    end
    return markers
  end

  # Create an array of map markers for a trip proxy. If the trip proxy is from an existing trip we will
  # have start and stop markers
  def create_trip_proxy_markers(trip_proxy, is_multi_od)
    markers = []
    if is_multi_od != true
      if trip_proxy.from_place_selected
        place = get_preselected_place(trip_proxy.from_place_selected_type, trip_proxy.from_place_selected, true)
      else
        place = {:name => trip_proxy.from_place, :lat => trip_proxy.from_lat, :lon => trip_proxy.from_lon, :formatted_address => trip_proxy.from_raw_address}
      end
      markers << get_addr_marker(place, 'start', 'startIcon')

      if trip_proxy.to_place_selected
        place = get_preselected_place(trip_proxy.to_place_selected_type, trip_proxy.to_place_selected, false)
      else
        place = {:name => trip_proxy.to_place, :lat => trip_proxy.to_lat, :lon => trip_proxy.to_lon, :formatted_address => trip_proxy.to_raw_address}
      end

      markers << get_addr_marker(place, 'stop', 'stopIcon')
    else
      multi_origin_places = []
      multi_origin_places = trip_proxy.multi_origin_places.split(';') unless trip_proxy.multi_origin_places.nil?

      multi_origin_places.each_with_index do |raw_place, index|
        place = JSON.parse(raw_place).symbolize_keys
        markers << get_addr_marker(place, 'start'+ (index+1).to_s, 'startIcon')
      end

      multi_dest_places = []
      multi_dest_places = trip_proxy.multi_dest_places.split(';') unless trip_proxy.multi_dest_places.nil?

      multi_dest_places.each_with_index do |raw_place, index|
        place = JSON.parse(raw_place).symbolize_keys
        markers << get_addr_marker(place, 'stop'+ (index+1).to_s, 'stopIcon')
      end

    end

    return markers
  end

  # Create an array of map markers suitable for the Leaflet plugin.
  def create_itinerary_markers(itinerary)

    trip = itinerary.trip_part.trip
    legs = itinerary.get_legs

    markers = []

    if legs
      legs.each do |leg|

        #place = {:name => leg.start_place.name, :lat => leg.start_place.lat, :lon => leg.start_place.lon, :address => leg.start_place.name}
        place = {:name => leg.short_description, :lat => leg.start_place.lat, :lon => leg.start_place.lon, :address => leg.start_place.name}
        markers << get_leg_start_marker(place, 'start_leg', 'blueMiniIcon')

        place = {:name => leg.end_place.name, :lat => leg.end_place.lat, :lon => leg.end_place.lon, :address => leg.end_place.name}
        markers << get_addr_marker(place, 'end_leg', 'blueMiniIcon')

      end
    end

    # Add start and stop after legs to place above other markers
    place = {:name => trip.from_place.name, :lat => trip.from_place.location.first, :lon => trip.from_place.location.last, :address => trip.from_place.address}

    markers << get_start_stop_marker(place, !itinerary.is_return_trip?)
    place = {:name => trip.to_place.name, :lat => trip.to_place.location.first, :lon => trip.to_place.location.last, :address => trip.to_place.address}
    markers << get_start_stop_marker(place, itinerary.is_return_trip?)

    return markers
  end

  # Returns a start or stop marker depending on boolean flag
  def get_start_stop_marker(place, is_start)
    if is_start
      get_addr_marker(place, 'start', 'startIcon')
    else
      get_addr_marker(place, 'stop', 'stopIcon')
    end
  end

  def query_sidewalk_feedback_near_one_walk_leg(leg)
    return [] unless (leg.mode == Leg::WALK and not leg.geometry.nil?)

    feedbacks = []
    min_lat = min_lon = max_lat = max_lon = nil
    leg.geometry.each do |latlon|
      lat = latlon[0]
      lon = latlon[1]
      min_lat = (min_lat.nil? or min_lat > lat) ? lat : min_lat
      min_lon = (min_lon.nil? or min_lon > lon) ? lon : min_lon
      max_lat = (max_lat.nil? or max_lat < lat) ? lat : max_lat
      max_lon = (max_lon.nil? or max_lon < lon) ? lon : max_lon
    end

    unless min_lat.nil?
      buffer = Oneclick::Application.config.sidewalk_feedback_query_buffer
      min_lat -= buffer#assign buffer
      max_lat += buffer
      min_lon -= buffer
      max_lon += buffer
      query_str = "(status = '%APPROVED_STATUS%'" #status valid?
      if @user.nil?
        is_admin = can? :manage, :all
      else
        @traveler = @user
        is_admin = @user.has_role?(:admin) or @user.has_role?(:system_administrator)
      end

      if is_admin #user permission
        query_str += " or status = '%PENDING_STATUS%') "
      else
        query_str += " or (status = '%PENDING_STATUS%' and user_id = %USER_ID%)) "
      end

      query_str += " and (removed_at IS NULL or removed_at >= '%LEG_START_TIME%')" #removed?
      query_str += " and (lat >= %MIN_LAT% and lat <= %MAX_LAT% and lon >= %MIN_LON% and lon <= %MAX_LON%)" #in bbox?

      query_str = query_str.
        sub('%APPROVED_STATUS%', SidewalkObstruction::APPROVED).
        sub('%PENDING_STATUS%', SidewalkObstruction::PENDING).
        sub('%USER_ID%', @traveler.id.to_s).
        sub('%LEG_START_TIME%', leg.start_time.to_s(:db)).
        sub('%MIN_LAT%', min_lat.to_s).
        sub('%MIN_LON%', min_lon.to_s).
        sub('%MAX_LAT%', max_lat.to_s).
        sub('%MAX_LON%', max_lon.to_s)

      Rails.logger.info query_str

      feedbacks = SidewalkObstruction.where(query_str)
    end

    feedbacks
  end

  #Returns an array of sidewalk_feedback_markers
  def create_itinerary_sidewalk_feedback_markers(legs)

    markers = []
    feedbacks = []
    legs.each do |leg|
      feedbacks.concat(query_sidewalk_feedback_near_one_walk_leg(leg))
    end

    is_admin = can? :manage, :all
    feedbacks.uniq.each do |f|
      markers << {
        data: f,
        allowed_actions: {
          is_approvable: (f.pending? and is_admin),
          is_deletable: (is_admin or current_or_guest_user.id == f.user.id)
        }
      }
    end
    return markers
  end

  #Returns an array of polylines, one for each leg
  def create_itinerary_polylines(legs)

    polylines = []
    legs.each_with_index do |leg, index|
      polylines << {
        "id" => index,
        "geom" => leg.geometry || [],
        "options" => get_leg_display_options(leg)
      }
    end

    return polylines
  end

  protected

  # Gets leaflet rendering hash for a leg based on the mode of the leg
  def get_leg_display_options(leg)

    if leg.mode.nil?
      a = {"className" => 'map-tripleg map-tripleg-unknown'}
    elsif leg.display_color.present?
      a = {"className" => "map-tripleg", "color" => leg.color}
    else
      a = {"className" => 'map-tripleg map-tripleg-' + leg.mode.downcase}
    end

    return a
  end

end
