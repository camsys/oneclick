class TaxiItinerary < Itinerary

  def self.get_taxi_itineraries(from, to, trip_datetime)

    itineraries = []

    taxi_mode = Mode.find_by_code("mode_taxi")
    taxi_services = Service.where("mode_id = ?", taxi_mode.id)

    # for now we will just use the first taxi service
    # if we want to support multiple services / legs in one trip or smart selection of service more refactoring is necessary
    selected_taxi_service = taxi_services.first

    taxi_services.each { |taxi_service|
      api_key = taxi_service.taxi_fare_finder_key
      city = taxi_service.taxi_fare_finder_city}
      results = TaxiRestService.call_out_to_taxi_fare_finder(city, api_key, from, to)
      Itinerary.new(results)
      itineraries.push(results)
    }
    
    return itineraries

  end

end
