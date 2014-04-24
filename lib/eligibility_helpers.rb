class EligibilityHelpers

  def get_eligible_services_for_traveler(user_profile, trip_part=nil)
    all_services = Service.active
    eligible_itineraries = []
    all_services.each do |service|
      itinerary = get_service_itinerary(service, user_profile, trip_part)
      if itinerary
        eligible_itineraries << itinerary
      end
    end

    #This is an array of itinerary hashes
    eligible_itineraries
  end

  def get_service_itinerary(service, user_profile, trip_part=nil)
    tp = TripPlanner.new
    min_match_score = Float::INFINITY
    itinerary = nil
    is_eligible = false
    missing_information = false
    missing_information_text = ''
    groups = service.service_characteristics.pluck(:group).uniq
    if groups.count == 0
      is_eligible = true
      min_match_score = 0
    end
    groups.each do |group|
      group_missing_information_text = ''
      group_match_score = 0
      group_eligible = true
      service_characteristic_maps = service.service_characteristics.where(group: group)
      service_characteristic_maps.each do |service_characteristic_map|
        service_requirement = service_characteristic_map.characteristic
        if service_requirement.code == 'age'
          if trip_part
            age_date = trip_part.trip_time
          else
            age_date = Time.now
          end

          update_age(user_profile, age_date)
        end

        passenger_characteristic = UserCharacteristic.where(user_profile_id: user_profile.id, characteristic_id: service_requirement.id)
        if passenger_characteristic.count == 0 #This passenger characteristic is not listed
          group_match_score += 0.25
          if service_requirement.code == 'age'
            if service_characteristic_map.value_relationship_id == 3 or service_characteristic_map.value_relationship_id == 4
              group_missing_information_text += 'persons ' + service_characteristic_map.value.to_s + ' years or older\n'
            elsif service_characteristic_map.value_relationship_id == 5 or service_characteristic_map.value_relationship_id == 6
              group_missing_information_text += 'persons ' + service_characteristic_map.value.to_s + ' years or younger\n'
            end
          else
            group_missing_information_text += service_requirement.desc + '\n'
          end
          next
        end
        if !test_condition(passenger_characteristic.first.value, service_characteristic_map.value_relationship_id , service_characteristic_map.value)
          group_eligible = false
          break
        end
      end
      if group_eligible
        is_eligible = true
        if group_match_score < min_match_score
          missing_information_text = group_missing_information_text
          min_match_score = group_match_score
        end
      end
    end

    if is_eligible
      #Create itinerary
      if min_match_score > 0.0
        missing_information = true
      end
      itinerary = tp.convert_paratransit_itineraries(service, min_match_score, missing_information, missing_information_text)
    end

    itinerary
  end

  def update_age(user_profile, date = Time.now)

    dob = Characteristic.find_by_code('date_of_birth')
    age = Characteristic.find_by_code('age')
    passenger_dob = UserCharacteristic.where(user_profile_id: user_profile.id, characteristic_id: dob.id)
    if passenger_dob.count != 0 && passenger_dob.first.value != 'na'
      passenger_dob = passenger_dob.first.value.to_date
    else
      return
    end
    passenger_age_characteristic = UserCharacteristic.find_or_initialize_by_user_profile_id_and_characteristic_id(user_profile.id, age.id)

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
    accommodations_maps = user_profile.user_accommodations.where('value = ? ', 'true')
    user_accommodations = []
    accommodations_maps.each do |map|
      user_accommodations << map.accommodation
    end

    #service accommodations
    accommodating_services = []
    #all_services = Service.all
    itineraries.each do |itinerary|
      service = itinerary['service']
      accommodations_maps = service.service_accommodations
      service_accommodations  = []
      accommodations_maps.each do |map|
        service_accommodations << map.accommodation
      end

      match_score = 0.5 * (user_accommodations.count - (service_accommodations & user_accommodations).count)
      if match_score > 0
        itinerary['accommodation_mismatch'] = true
      end
      itinerary['match_score'] += match_score.to_f
      missing_accommodations = user_accommodations - service_accommodations
      missing_accommodations.each do |accommodation|
        itinerary['missing_accommodations'] += (accommodation.name + ',')
      end

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
    itineraries = find_bookable_itineraries(trip_part, itineraries)
    itineraries
  end

  def find_bookable_itineraries(trip_part, itineraries)
    #see if the traveler is registered with any of these services
    traveler = trip_part.trip.user
    itineraries.each do |itinerary|
      if itinerary['service'].nil?
        next
      end
      user_service = UserService.where(user_profile: traveler.user_profile, service: itinerary['service']).first
      if user_service and not user_service.disabled
        itinerary['is_bookable'] = true
      end
    end
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

      #Todo: If the user does not list his home, then this itinerary is thrown out.  Instead, we should show the itinerary
      #but warn that we don't know the user's home address.
      coverages = service.service_coverage_maps.where(rule: 'residence').type_polygon
      if !coverages.empty? and trip_part.user.home.nil?
        next
      end
      within = coverages.empty?
      coverages.each do |coverage|
        if coverage.geo_coverage.polygon_contains?(trip_part.user.home.lon, trip_part.user.home.lat)
          within = true
          break
        end
      end

      unless within
        next
      end

      #Match Origin
      coverages = service.service_coverage_maps.where(rule: 'origin').map {|c| c.geo_coverage.value.delete(' ').downcase}
      county_name = trip_part.from_trip_place.county_name || ""
      unless (coverages.count == 0) or (trip_part.from_trip_place.zipcode.in? coverages) or (county_name.delete(' ').downcase.in? coverages)
        next
      end

      coverages = service.service_coverage_maps.where(rule: 'origin').type_polygon
      within = coverages.empty?
      coverages.each do |coverage|
        if coverage.geo_coverage.polygon_contains?(trip_part.from_trip_place.lon, trip_part.from_trip_place.lat)
          within = true
          break
        end
      end

      unless within
        next
      end

      #Match Destination
      county_name = trip_part.to_trip_place.county_name || ""
      coverages = service.service_coverage_maps.where(rule: 'destination').map {|c| c.geo_coverage.value.delete(' ').downcase}
      unless (coverages.count == 0) or (trip_part.to_trip_place.zipcode.in? coverages) or (county_name.delete(' ').downcase.in? coverages)
        next
      end

      coverages = service.service_coverage_maps.where(rule: 'destination').type_polygon
      within = coverages.empty?
      coverages.each do |coverage|
        if coverage.geo_coverage.polygon_contains?(trip_part.to_trip_place.lon, trip_part.to_trip_place.lat)
          within = true
          break
        end
      end

      unless within
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
      if purposes.include? trip_part.trip.trip_purpose or purposes.count == 0
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
        itinerary['date_mismatch'] = true
      end
      schedules.each do |schedule|
        # puts "%-30s %-30s %s" % [Time.zone, planned_trip.trip_datetime, planned_trip.trip_datetime.seconds_since_midnight]
        # puts "%-30s %-30s %s" % [Time.zone, schedule.start_time, schedule.start_time.seconds_since_midnight]
        # puts "%-30s %-30s %s" % [Time.zone, schedule.end_time, schedule.end_time.seconds_since_midnight]
        unless trip_part.trip_time.seconds_since_midnight.between?(schedule.start_seconds,schedule.end_seconds)
          itinerary['match_score'] += 1
          itinerary['time_mismatch'] = true
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
        itinerary['match_score'] += 0.01
        itinerary['too_late'] = true
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

  def relationship_to_words(operator)
    case operator
      when 1 # general equals
        return "equal to"
      when 2 # float equals
        return "equal to"
      when 3 # greater than
        return "greater than"
      when 4 # greather than or equal
        return "at least"
      when 5 # less than
        return "less than"
      when 6 # less than or equal
        return "less than or equal to"
      else
        return ""
    end
  end
end
