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
    my_fare = itinerary.service.fare_structures.where(fare_type: 0).order(:base).first

    if my_fare
      itinerary.cost = my_fare.base
      itinerary.cost_comments= my_fare.desc
    else
      itinerary.cost_comments = itinerary.service.fare_structures.where(fare_type: 2).pluck(:desc).first
    end

    itinerary.save
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

end