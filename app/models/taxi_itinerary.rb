class TaxiItinerary < Itinerary

  def calculate_fare
    if self.cost.blank?
      base_rate = self.service.fare_structures.first.base
      # we don't have mileage currently, so not calculating the variable portion
      #variable_rate = self.service.fare_structures.first.rate
      self.cost = base_rate
      self.save
    end
  end

  def self.get_taxi_itineraries(from, to, trip_datetime, trip_user)

    itineraries = []

    taxi_mode = Mode.find_by_code("mode_taxi")
    taxi_services = Service.where("mode_id = ?", taxi_mode.id)

    api_key = Oneclick::Application.config.taxi_fare_finder_api_key

    taxi_services.each do |taxi_service|
      taxi_service_match = taxi_service.is_valid_for_trip_area(from, to)
      taxi_service_match = taxi_service.can_provide_user_accommodations(trip_user, taxi_service) if (trip_user.present? && taxi_service_match)
      if (taxi_service_match)
        city = taxi_service.taxi_fare_finder_city
        if city.present?
          results = TaxiRestService.call_out_to_taxi_fare_finder(city, api_key, from, to)
          new_itinerary = TaxiItinerary.new(results)
        else
          new_itinerary = TaxiItinerary.new
          
          new_itinerary.duration = 0
        end
        new_itinerary.returned_mode_code = taxi_mode.code
        new_itinerary.mode = taxi_mode
        new_itinerary.service = taxi_service
        new_itinerary.calculate_fare

        itineraries.push(new_itinerary)
      end
    end
    
    return itineraries

  end

end