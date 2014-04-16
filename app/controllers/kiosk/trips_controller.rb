module Kiosk
  class TripsController < ::TripsController
    include Behavior

    def show
      if params[:back]
        session[:current_trip_id] = @trip.id
        redirect_to new_user_characteristic_path_for_ui_mode(@traveler, inline: 1)
        return
      end

      super
    end

    def itinerary_print
      @itinerary = Itinerary.find(params[:id])
      @legs = @itinerary.get_legs
      @itinerary = ItineraryDecorator.decorate(@itinerary)
      @hide_timeout = true
    end

  # Creates a trip object from a trip proxy
  def create_trip(trip_proxy)
    Rails.logger.info "TripsController#create_trip"
    Rails.logger.info trip_proxy.ai
    
    trip = Trip.new()
    trip.creator = current_or_guest_user
    trip.user = @traveler
    trip.trip_purpose = TripPurpose.find(trip_proxy.trip_purpose_id)

    # get the start for this trip
    from_place = TripPlace.new()
    from_place.sequence = 0
    place = get_preselected_place(trip_proxy.from_place_selected_type, trip_proxy.from_place_selected, true)
    if place[:poi_id]
      from_place.poi = Poi.find(place[:poi_id])
    elsif place[:place_id]
      from_place.place = @traveler.places.find(place[:place_id])
    else
      from_place.raw_address = place[:formatted_address]
      from_place.address1 = place[:street_address]
      from_place.city = place[:city]
      from_place.state = place[:state]
      from_place.zip = place[:zip]
      from_place.county = place[:county]
      from_place.lat = place[:lat]
      from_place.lon = place[:lon]
      from_place.raw = place[:raw]
    end

    #If from_is_home, set the from place as home.
    unless trip_proxy.from_is_home.to_i == 0
      unless place[:place_id]
        new_place = Place.new
        new_place.user = @traveler
        new_place.creator = current_user
        new_place.raw_address = from_place.raw_address
        new_place.name = 'My Home'
        new_place.address1 = from_place.address1
        new_place.address2 = from_place.address2
        new_place.city = from_place.city
        new_place.state = from_place.state
        new_place.zip = from_place.zip
        new_place.county = from_place.county
        new_place.lat = from_place.lat
        new_place.lon = from_place.lon
        new_place.active = true
        from_place.place = new_place

        @traveler.clear_home
        new_place.home = true
        new_place.save
      else

        @traveler.clear_home
        from_place.place.home = true
        from_place.place.save
      end
    end

    # get the end for this trip
    to_place = TripPlace.new()
    to_place.sequence = 1
    place = get_preselected_place(trip_proxy.to_place_selected_type, trip_proxy.to_place_selected, false)
    if place[:poi_id]
      to_place.poi = Poi.find(place[:poi_id])
    elsif place[:place_id]
      to_place.place = @traveler.places.find(place[:place_id])
    else
      to_place.raw_address = place[:formatted_address]
      to_place.address1 = place[:street_address]
      to_place.city = place[:city]
      to_place.state = place[:state]
      to_place.zip = place[:zip]
      to_place.county = place[:county]
      to_place.lat = place[:lat]
      to_place.lon = place[:lon]
      to_place.raw = place[:raw]
    end


    #If to_is_home, set the to place as home.
    unless trip_proxy.to_is_home.to_i == 0
      unless place[:place_id]
        new_place = Place.new
        new_place.user = @traveler
        new_place.creator = current_user
        new_place.raw_address = to_place.raw_address
        new_place.name = 'My Home'
        new_place.address1 = to_place.address1
        new_place.address2 = to_place.address2
        new_place.city = to_place.city
        new_place.state = to_place.state
        new_place.zip = to_place.zip
        new_place.county = to_place.county
        new_place.lat = to_place.lat
        new_place.lon = to_place.lon
        new_place.active = true
        to_place.place = new_place

        @traveler.clear_home
        new_place.home = true
        new_place.save
      else

        @traveler.clear_home
        to_place.place.home = true
        to_place.place.save
      end
    end

    raise "from place not valid: #{from_place.errors.messages}" unless from_place.valid?
    raise "to place not valid: #{to_place.errors.messages}" unless to_place.valid?

    # add the places to the trip
    trip.trip_places << from_place
    trip.trip_places << to_place

    # Create the trip parts. For now we only have at most two but there could be more
    # in later versions

    # set the sequence counter for when we have multiple trip parts
    sequence = 0

    trip_date = Date.strptime(trip_proxy.trip_date, '%m/%d/%Y')

    # Create the outbound trip part
    trip_part = TripPart.new
    trip_part.trip = trip
    trip_part.sequence = sequence
    trip_part.is_depart = trip_proxy.arrive_depart == t(:departing_at) ? true : false
    trip_part.scheduled_date = trip_date
    trip_part.scheduled_time = Time.zone.parse(trip_proxy.trip_time)
    trip_part.from_trip_place = from_place
    trip_part.to_trip_place = to_place

    raise 'TripPart not valid' unless trip_part.valid?
    trip.trip_parts << trip_part

    # create the round trip if needed
    if trip_proxy.is_round_trip == "1"
      sequence += 1
      trip_part = TripPart.new
      trip_part.trip = trip
      trip_part.sequence = sequence
      trip_part.is_depart = true
      trip_part.is_return_trip = true
      trip_part.scheduled_date = trip_date
      trip_part.scheduled_time = Time.zone.parse(trip_proxy.return_trip_time)
      trip_part.from_trip_place = to_place
      trip_part.to_trip_place = from_place

      raise 'TripPart not valid' unless trip_part.valid?
      trip.trip_parts << trip_part
    end

    return trip
  end

  protected

    def back_url
      if params[:action] == 'show'
        url_for(back: true)
      end
    end
  end
end
