class FareHelper

  #Check to see if we should calculate the fare locally or use a third-party service.
  def calculate_fare(trip_part, itinerary)
    #Check to see if this user is registered to book directly with this service
    service = Service.find(itinerary['service_id'])
    up = UserService.where(user_profile: trip_part.trip.user.user_profile, service: itinerary.service)
    if up.count > 0
      return query_fare(itinerary)
    else
      return calculate_fare_locally(trip_part, itinerary)
    end
  end

  #Caculate Fare based on stored fare rules
  def calculate_fare_locally(trip_part, itinerary)
    is_paratransit = itinerary.service.is_paratransit? rescue false

    if is_paratransit
      cost = calculate_paratransit_itinerary_cost(itinerary)
      if cost
        itinerary.cost = cost
        itinerary.save
      end
    else
      my_fare = itinerary.service.fare_structures.where(fare_type: 0).order(:base).first

      if my_fare
        itinerary.cost = my_fare.base
        itinerary.cost_comments= my_fare.desc
      else
        itinerary.cost_comments = itinerary.service.fare_structures.where(fare_type: 2).pluck(:desc).first
      end

      itinerary.save
    end
  end

  #Get the fare from a third-party source (e.g., a booking agent.)
  def query_fare(itinerary)
    case itinerary.service.booking_service_code
    when 'ecolane'
      eh = EcolaneHelpers.new
      result, my_fare =  eh.query_fare(itinerary)
      if result
        itinerary.cost = my_fare
      end

      itinerary.save
    end
  end

  #Allows a global multiplier for fixed-route fare if a travler's age is greater than config.discount_fare_age AND config.discount_fare_active is true
  def calculate_fixed_route_fare(trip_part, itinerary)

    #Check for multipliers
    if Oneclick::Application.config.discount_fare_active and trip_part.trip.user.age and trip_part.trip.user.age > Oneclick::Application.config.discount_fare_age
      itinerary.cost *= Oneclick::Application.config.discount_fare_multiplier
      itinerary.save
    end

    #Check for comments.
    begin
      itinerary.cost_comments = itinerary.service.fare_structures.pluck(:desc).first
      itinerary.save
    rescue
      return
    end

  end

  # TODO: needs to be refactored into ParatransitItinerary model
  def calculate_paratransit_itinerary_cost itinerary
    fare_structure = itinerary.service.fare_structures.first rescue nil

    if fare_structure
      case fare_structure.fare_type
      when FareStructure::FLAT
        flat_fare = fare_structure.flat_fare

        if flat_fare && flat_fare.one_way_rate
          fare = flat_fare.one_way_rate.to_f
        end
      when FareStructure::MILEAGE
        mileage_fare = fare_structure.mileage_fare
        if mileage_fare && mileage_fare.base_rate

          if mileage_fare.mileage_rate
            trip_part = itinerary.trip_part
            is_return_trip = trip_part.is_return_trip
            trip_places = trip_part.trip.trip_places
            if is_return_trip
              start_lat = trip_places.last.lat 
              start_lng = trip_places.last.lon
              end_lat = trip_places.first.lat 
              end_lng = trip_places.first.lon
            else
              start_lat = trip_places.first.lat 
              start_lng = trip_places.first.lon
              end_lat = trip_places.last.lat 
              end_lng = trip_places.last.lon
            end

            mileage = TripPlanner.new.get_drive_distance(
              !trip_part.is_depart, 
              trip_part.scheduled_time, 
              start_lat, start_lng, 
              end_lat, end_lng)

            if mileage
              fare = mileage_fare.base_rate.to_f + mileage * mileage_fare.mileage_rate.to_f
            else
              fare = mileage_fare.base_rate.to_f
            end
          else
            fare = mileage_fare.base_rate.to_f
          end
        end
      when FareStructure::ZONE
        is_return_trip = itinerary.trip_part.is_return_trip
        trip_places = itinerary.trip_part.trip.trip_places
        if is_return_trip
          start_lat = trip_places.last.lat 
          start_lng = trip_places.last.lon
          end_lat = trip_places.first.lat 
          end_lng = trip_places.first.lon
        else
          start_lat = trip_places.first.lat 
          start_lng = trip_places.first.lon
          end_lat = trip_places.last.lat 
          end_lng = trip_places.last.lon
        end

        fare = fare_structure.zone_fare(start_lat, start_lng, end_lat, end_lng)
      end
    end

    fare
  end

end