class ParatransitItinerary < Itinerary

  def self.calculate_fare(itinerary, skip_calculation = false)
    estimated = false
    price_formatted = nil
    cost_in_words = ''
    comments = ''
    fare = nil

    fare = itinerary.cost
    fare_structure = itinerary.service.fare_structures.first rescue nil
    trip_part = itinerary.trip_part

    if fare_structure
      case fare_structure.fare_type
      when FareStructure::FLAT
        flat_fare = fare_structure.flat_fare
        if !skip_calculation
          fare = fare_structure.flat_fare_number
        end

        if fare
          fare = fare.to_f
          price_formatted = "$#{fare}"
          cost_in_words = price_formatted

          if flat_fare.round_trip_rate
            price_formatted +=  '*'
            comments = "#{I18n.t(:one_way_rate)}: #{flat_fare.one_way_rate}; #{I18n.t(:round_trip_rate)}: #{flat_fare.round_trip_rate}"
          end
        end

      when FareStructure::MILEAGE
        mileage_fare = fare_structure.mileage_fare
        estimated = true
        if !skip_calculation
          fare = fare_structure.mileage_fare_number(trip_part)
        end

        if fare
          if mileage_fare.mileage_rate
            comments = "#{I18n.t(:base_rate)}: $#{mileage_fare.base_rate}; $#{mileage_fare.mileage_rate}/mile - " + I18n.t(:cost_estimated)
          else
            comments = I18n.t(:mileage_rate_not_available)
          end

          price_formatted = "$#{fare.ceil}*"
          cost_in_words = "$#{fare.ceil} #{I18n.t(:est)}"
        end
      when FareStructure::ZONE
        if !skip_calculation
          fare = fare_structure.zone_fare_number(trip_part)
        end
      end
    end

    if price_formatted.nil? && fare.nil?
      estimated = true
      price_formatted = '*'
      comments = I18n.t(:see_details_for_cost)
      cost_in_words = I18n.t(:unknown)
    else
      if !skip_calculation
        itinerary.cost = fare
      end
    end

    {
      estimated: estimated,
      fare: fare,
      price_formatted: price_formatted,
      cost_in_words: cost_in_words,
      comments: comments
    }
  end

  def self.get_itineraries(trip_part)

    eh = EligibilityService.new
    fh = FareHelper.new
    itins = eh.get_accommodating_and_eligible_services_for_traveler(trip_part)
    itins = eh.remove_ineligible_itineraries(trip_part, itins)

    itins = itins.collect do |itinerary|
      new_itinerary = ParatransitItinerary.new(itinerary)
      new_itinerary.trip_part = trip_part
      ParatransitItinerary.calculate_fare new_itinerary
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