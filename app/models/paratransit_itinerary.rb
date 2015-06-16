class ParatransitItinerary < Itinerary

  def self.get_itineraries(trip_part)

    eh = EligibilityService.new
    fh = FareHelper.new
    itins = eh.get_accommodating_and_eligible_services_for_traveler(trip_part)
    itins = eh.remove_ineligible_itineraries(trip_part, itins)

    itins = itins.collect do |itinerary|
      new_itinerary = ParatransitItinerary.new(itinerary)
      new_itinerary.trip_part = trip_part
      fh.calculate_fare new_itinerary
      new_itinerary
    end

    ParatransitItinerary.estimate_duration(itins)

  end

  private

  def self.estimate_duration(itins)
    unless itins.empty?

      unless ENV['SKIP_DYNAMIC_PARATRANSIT_DURATION']
        trip_part = itins.first.trip_part
        is_depart = trip_part.is_depart
        trip_time = trip_part.trip_time
        from_trip_place = trip_part.from_trip_place
        to_trip_place = trip_part.to_trip_place

        begin
          base_duration = TripPlanner.new.get_drive_time(
            !is_depart, trip_time, 
            from_trip_place.location.first, from_trip_place.location.last, 
            to_trip_place.location.first, to_trip_place.location.last)[0]
        rescue Exception => e
          Rails.logger.error "Exception #{e} while getting trip duration."
          base_duration = nil
        end
      else
        Rails.logger.info "SKIP_DYNAMIC_PARATRANSIT_DURATION is set, skipping it"
        base_duration = Oneclick::Application.config.default_paratransit_duration
      end

      Rails.logger.info "Base duration: #{base_duration} minutes"
      itins.each do |i|
        service_window = i.service.service_window if i && i.service
        i.estimate_duration(base_duration, Oneclick::Application.config.minimum_paratransit_duration,
                            i.service.time_factor || Oneclick::Application.config.paratransit_duration_factor, service_window, trip_time, is_depart)
      end
    end

    itins
  end

end