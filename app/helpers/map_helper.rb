module MapHelper

  ALPHABET = ('A'..'Z').to_a

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
      "description" => render_to_string(:partial => "/shared/map_popup", :locals => { :place => {:icon => 'fa-building-o', :name => place.name, :address => place.address} })
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
  def create_trip_proxy_markers(trip_proxy)

    markers = []
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

    return markers
  end

  # Create an array of map markers suitable for the Leaflet plugin.
  def create_itinerary_markers(itinerary)

    trip = itinerary.trip_part.trip
    legs = itinerary.get_legs

    markers = []

    if legs
      legs.each do |leg|

        place = {:name => leg.start_place.name, :lat => leg.start_place.lat, :lon => leg.start_place.lon, :address => leg.start_place.name}
        markers << get_addr_marker(place, 'start_leg', 'blueMiniIcon')

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
      
  #Returns an array of polylines, one for each leg
  def create_itinerary_polylines(legs)

    polylines = []
    legs.each_with_index do |leg, index|
      polylines << {
        "id" => index,
        "geom" => leg.geometry,
        "options" => get_leg_display_options(leg)
      }
    end

    return polylines
  end

protected

  # Gets leaflet rendering hash for a leg based on the mode of the leg
  def get_leg_display_options(leg)

    if leg.mode == Leg::TripLeg::WALK
      a = {"color" => 'red', "width" => "5"}
    elsif leg.mode == Leg::TripLeg::BUS
      a = {"color" => 'blue', "width" => "5"}
    elsif leg.mode == Leg::TripLeg::SUBWAY
      a = {"color" => 'green', "width" => "5"}
    elsif leg.mode == Leg::TripLeg::CAR
      a = {"color" => 'yellow', "width" => "5"}
    else
      a = {}
    end

    return a
  end

end
