class EligibilityHelpers

  def get_eligible_services_for_traveler(user_profile, trip_part=nil)
    tp = TripPlanner.new
    all_services = Service.all
    eligible_itineraries = []
    all_services.each do |service|
      match_score = 0
      is_eligible = true
      service_characteristic_maps = service.service_traveler_characteristics_maps
      service_characteristic_maps.each do |service_characteristic_map|
        service_requirement = service_characteristic_map.traveler_characteristic
        if service_requirement.code = 'age'
          if trip_part
            age_date = trip_part.trip_time
          else
            age_date = Time.now
          end

          update_age(user_profile, age_date)
        end

        passenger_characteristic = UserTravelerCharacteristicsMap.where(user_profile_id: user_profile.id, characteristic_id: service_requirement.id)
        if passenger_characteristic.count == 0 #This passenger characteristic is not listed
          match_score += 0.25
          break
        end
        if !test_condition(passenger_characteristic.first.value, service_characteristic_map.value_relationship_id , service_characteristic_map.value)
          is_eligible = false
          break
        end
      end
      if is_eligible
        #Create itinerary
        itinerary = tp.convert_paratransit_itineraries(service, match_score)
        eligible_itineraries << itinerary
      end
    end
    #Thisis an array of itinerary hashes
    eligible_itineraries

  end

  def update_age(user_profile, date = Time.now)

    dob = TravelerCharacteristic.find_by_code('date_of_birth')
    age = TravelerCharacteristic.find_by_code('age')
    passenger_dob = UserTravelerCharacteristicsMap.where(user_profile_id: user_profile.id, characteristic_id: dob.id)
    if passenger_dob.count != 0 && passenger_dob.first.value != 'na'
      passenger_dob = passenger_dob.first.value.to_date
    else
      return
    end
    passenger_age_characteristic = UserTravelerCharacteristicsMap.find_or_initialize_by_user_profile_id_and_characteristic_id(user_profile.id, age.id)

    new_age = date.year - passenger_dob.year
    new_age -= 1 if date < passenger_dob + new_age.years
    passenger_age_characteristic.value = new_age
    passenger_age_characteristic.save()

  end


  def get_accommodating_services_for_traveler(itineraries, user_profile)

    if user_profile.nil?
      return []
    end

    #user accommodations
    accommodations_maps = user_profile.user_traveler_accommodations_maps.where('value = ? ', 'true')
    user_accommodations = []
    accommodations_maps.each do |map|
      user_accommodations << map.traveler_accommodation
    end

    #service accommodations
    accommodating_services = []
    #all_services = Service.all
    itineraries.each do |itinerary|
      service = itinerary['service']
      accommodations_maps = service.service_traveler_accommodations_maps
      service_accommodations  = []
      accommodations_maps.each do |map|
        service_accommodations << map.traveler_accommodation
      end

      match_score = 0.5 * (user_accommodations.count - (service_accommodations & user_accommodations).count)
      itinerary['match_score'] += match_score.to_f

    end

    itineraries

  end

  def get_accommodating_and_eligible_services_for_traveler(trip_part=nil)

    user_profile = trip_part.trip.user.user_profile unless trip_part.nil?
    
    if user_profile.nil? #TODO:  Need to update to handle anonymous users.  This currently only works with user logged in.
      return []
    end

    Rails.logger.debug "Get eligible services"
    eligible = get_eligible_services_for_traveler(user_profile, trip_part)
    Rails.logger.debug "Done get eligible services, get accommodating"
    #Creating set of itineraries

    itineraries = get_accommodating_services_for_traveler(eligible, user_profile)
    #Rails.logger.debug "Done get accommodating"
    #Rails.logger.debug eligible.ai
    #Rails.logger.debug accommodating.ai
    itineraries

  end

  def get_eligible_services_for_trip(trip_part, itineraries)
    itineraries = eligible_by_location(trip_part, itineraries)
    itineraries = eligible_by_service_time(trip_part, itineraries)
    itineraries = eligible_by_advanced_notice(trip_part, itineraries)
    itineraries = eligible_by_trip_purpose(trip_part, itineraries)

    #eligible_by_location & eligible_by_service_time & eligible_by_advanced_notice & eligible_by_trip_purpose
    itineraries
  end

  def eligible_by_location(trip_part, itineraries)

    eligible_itineraries  = []
    itineraries.each do |itinerary|
      service = itinerary['service']
      #Match Residence
      coverages = service.service_coverage_maps.where(rule: 'residence').map {|c| c.geo_coverage.value.delete(' ').downcase}
      if trip_part.trip.user.home
        county_name = trip_part.trip.user.home.county_name || ""
        zipcode = trip_part.trip.user.home.zipcode
      else
        county_name = ""
        zipcode = ""
      end
      unless (coverages.count == 0) or (zipcode.in? coverages) or (county_name.delete(' ').downcase.in? coverages)
        next
      end

      #Match Origin
      coverages = service.service_coverage_maps.where(rule: 'origin').map {|c| c.geo_coverage.value.delete(' ').downcase}
      county_name = trip_part.from_trip_place.county_name || ""
      unless (coverages.count == 0) or (trip_part.from_trip_place.zipcode.in? coverages) or (county_name.delete(' ').downcase.in? coverages)
        next
      end

      #Match Destination
      county_name = trip_part.to_trip_place.county_name || ""
      coverages = service.service_coverage_maps.where(rule: 'destination').map {|c| c.geo_coverage.value.delete(' ').downcase}
      unless (coverages.count == 0) or (trip_part.to_trip_place.zipcode.in? coverages) or (county_name.delete(' ').downcase.in? coverages)
        next
      end

      eligible_itineraries << itinerary
    end
    eligible_itineraries
  end

  def eligible_by_trip_purpose(trip_part, itineraries)

    eligible_itineraries = []
    itineraries.each do |itinerary|
      service = itinerary['service']
      maps = service.service_trip_purpose_maps
      purposes = []
      maps.each do |map|
        purposes << map.trip_purpose
      end
      if purposes.include? trip_part.trip.trip_purpose
        eligible_itineraries << itinerary
      end
    end

    eligible_itineraries

  end

  def eligible_by_service_time(trip_part, itineraries)
    #TODO: This does not handle services with 24 hour operations well.
    wday = trip_part.trip_time.wday
    itineraries.each do |itinerary|
      service = itinerary['service']
      schedules = Schedule.where(day_of_week: wday, service_id: service.id)
      if schedules.count == 0
        itinerary['match_score'] += 1
      end
      schedules.each do |schedule|
        # puts "%-30s %-30s %s" % [Time.zone, planned_trip.trip_datetime, planned_trip.trip_datetime.seconds_since_midnight]
        # puts "%-30s %-30s %s" % [Time.zone, schedule.start_time, schedule.start_time.seconds_since_midnight]
        # puts "%-30s %-30s %s" % [Time.zone, schedule.end_time, schedule.end_time.seconds_since_midnight]
        unless trip_part.trip_time.seconds_since_midnight.between?(schedule.start_time.seconds_since_midnight,schedule.end_time.seconds_since_midnight)
          itinerary['match_score'] += 1
        end
      end
    end

    itineraries

  end

  def eligible_by_advanced_notice(trip_part, itineraries)
    advanced_notice = (trip_part.trip_time.to_time - trip_part.created_at)/60

    itineraries.each do |itinerary|
      notice_required = itinerary['service'].advanced_notice_minutes
      if notice_required > advanced_notice
        itinerary['match_score'] += 0.5
      end
    end

    itineraries

  end

  def test_condition(value1, operator, value2)
    case operator
      when 1 # general equals
        return value1 == value2
      when 2 # float equals
        return value1.to_f == value2.to_f
      when 3 # greater than
        return value1.to_f > value2.to_f
      when 4 # greather than or equal
        return value1.to_f >= value2.to_f
      when 5 # less than
        return value1.to_f < value2.to_f
      when 6 # less than or equal
        return value1.to_f <= value2.to_f
      else
        return false
      end
    end

 end
