class TaxiItinerary < Itinerary

  def calculate_fare
    if self.cost.blank?
      fs = self.service.fare_structures.first
      cost = fs.mileage_fare ? fs.mileage_fare_number(self.trip_part) : fs.base
      self.update_attributes(cost: cost)
    end
  end

  def estimate_duration passed_trip_part
    base_duration = TripPlanner.new.get_drive_time(!passed_trip_part.is_depart, passed_trip_part.trip_time, passed_trip_part.from_trip_place.location.first, passed_trip_part.from_trip_place.location.last, passed_trip_part.to_trip_place.location.first, passed_trip_part.to_trip_place.location.last)[0]
  end

  def self.get_taxi_itineraries(passed_trip_part, from, to, trip_datetime, trip_user)

    itineraries = []

    taxi_mode = Mode.find_by_code("mode_taxi")
    taxi_services = TaxiService.where("mode_id = ?", taxi_mode.id)

    api_key = Oneclick::Application.config.taxi_fare_finder_api_key

    taxi_services.each do |taxi_service|
      taxi_service_match = taxi_service.is_valid_for_trip_area(from, to) && taxi_service.is_valid_for_trip_schedule(passed_trip_part)
      #taxi_service_match = taxi_service.can_provide_user_accommodations(trip_user, taxi_service) if (trip_user.present? && taxi_service_match)

      if (taxi_service_match)
        city = taxi_service.taxi_fare_finder_city
        if city.present?
          results = TaxiRestService.call_out_to_taxi_fare_finder(city, api_key, [from.lat.to_f, from.lon.to_f], [to.lat.to_f, to.lon.to_f])
          if results.present?
            new_itinerary = TaxiItinerary.new(results)
            new_itinerary.trip_part = passed_trip_part
          end
        else
          new_itinerary = TaxiItinerary.new
          new_itinerary.trip_part = passed_trip_part
          new_itinerary.duration = new_itinerary.estimate_duration(passed_trip_part)
        end

        if new_itinerary.present?
          new_itinerary.returned_mode_code = taxi_mode.code
          new_itinerary.mode = taxi_mode
          new_itinerary.service = taxi_service
          new_itinerary.calculate_fare
          new_itinerary.server_status = 200
          new_itinerary.wait_time = 900

          #Add the estimated start_time and end_time for this itinerary
          if passed_trip_part.is_depart
            new_itinerary.start_time = passed_trip_part.scheduled_time + new_itinerary.wait_time
            unless new_itinerary.duration.nil?
              new_itinerary.end_time = passed_trip_part.scheduled_time + new_itinerary.duration + new_itinerary.wait_time
            end
          else
            new_itinerary.end_time = passed_trip_part.scheduled_time
            unless new_itinerary.duration.nil?
              new_itinerary.start_time = passed_trip_part.scheduled_time - new_itinerary.duration
            end
          end

          itineraries.push(new_itinerary)

        end
      end
    end

    return itineraries

  end

end
