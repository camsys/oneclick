class EligibilityService
  include EligibilityOperators

  def get_eligible_services_for_traveler(user_profile, trip_part=nil, return_with=:itinerary)
    all_services = Service.paratransit.active
    eligible_itineraries = []
    all_services.each do |service|
      itinerary = get_service_itinerary(service, user_profile, trip_part, return_with)
      if itinerary
        eligible_itineraries << itinerary
      end
    end

    #This is an array of itinerary hashes
    eligible_itineraries
  end

  def get_service_itinerary(service, user_profile, trip_part=nil, return_with=:itinerary)
    tp = TripPlanner.new
    min_match_score = Float::INFINITY
    itinerary = nil
    is_eligible = false
    missing_information = false
    missing_information_text = ''
    missing_info = []
    groups = service.service_characteristics.pluck(:group).uniq rescue []
    if groups.count == 0
      is_eligible = true
      min_match_score = 0
    end
    groups.each do |group|
      group_missing_information_text = ''
      group_missing_info = []
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
            if service_characteristic_map.rel_code == 3 or service_characteristic_map.rel_code == 4
              group_missing_information_text += 'persons ' + service_characteristic_map.value.to_s + ' years or older\n'
              group_missing_info << service_requirement.for_missing_info(service, group, service_requirement.code)
            elsif service_characteristic_map.rel_code == 5 or service_characteristic_map.rel_code == 6
              group_missing_information_text += 'persons ' + service_characteristic_map.value.to_s + ' years or younger\n'
              group_missing_info << service_requirement.for_missing_info(service, group, service_requirement.code)
            end
          else
            group_missing_information_text += service_requirement.desc + '\n'
            group_missing_info << service_requirement.for_missing_info(service, group, service_requirement.code)
          end
          next
        end

        # Passenger does have a value for the characteristic, so test it
        if !test_condition(passenger_characteristic.first.value, service_characteristic_map.rel_code , service_characteristic_map.value)
          group_eligible = false
          break
        end
      end  # service_characteristic_maps.each do

      if group_eligible
        is_eligible = true
        if group_match_score < min_match_score
          missing_information_text = group_missing_information_text
          min_match_score = group_match_score
        end
        missing_info << group_missing_info
      end

    end # groups.each do

    if is_eligible
      #Create itinerary
      if min_match_score > 0.0
        missing_information = true
      else
        missing_info = []
      end
      itinerary = tp.convert_paratransit_itineraries(service, min_match_score, missing_information, missing_information_text)
      # itinerary['missing_info'] = missing_info.flatten
    end

    case return_with
    when :itinerary
      return itinerary    
    when :missing_info
      return missing_info.flatten
    end
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
    Rails.logger.debug "Done get accommodating"
    Rails.logger.debug eligible.ai
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

    factory = RGeo::Geographic.simple_mercator_factory

    eligible_itineraries  = []
    itineraries.each do |itinerary|
      service = itinerary['service']

      #Match Residence
      if service.residence?
        if trip_part.trip.user.home.nil?
          next
        end
        point = factory.point(trip_part.user.home.lon.to_f, trip_part.user.home.lat.to_f)
        unless service.residence.contains? point
          next
        end

      else
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
      end

      #Match Origin
      #if the service has a polygon boundary, it supercedes the attributes
      if service.origin?
        point = factory.point(trip_part.from_trip_place.lon.to_f, trip_part.from_trip_place.lat.to_f)
        unless service.origin.contains? point
          next
        end
      else
        coverages = service.service_coverage_maps.where(rule: 'origin').map {|c| c.geo_coverage.value.delete(' ').downcase}
        county_name = trip_part.from_trip_place.county_name || ""
        unless (coverages.count == 0) or (trip_part.from_trip_place.zipcode.in? coverages) or (county_name.delete(' ').downcase.in? coverages)
          next
        end
      end

      #Match Destination
      if service.destination?
        point = factory.point(trip_part.to_trip_place.lon.to_f, trip_part.to_trip_place.lat.to_f)
        unless service.destination.contains? point
          next
        end
      else
        county_name = trip_part.to_trip_place.county_name || ""
        coverages = service.service_coverage_maps.where(rule: 'destination').map {|c| c.geo_coverage.value.delete(' ').downcase}
        unless (coverages.count == 0) or (trip_part.to_trip_place.zipcode.in? coverages) or (county_name.delete(' ').downcase.in? coverages)
          next
        end
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

  # Generate a string from an array of service_characteristics
  # TODO: translate strings for special code cases
  def service_characteristics_group_to_s(group)
    translated = group.map do |m|
      translate_service_characteristic_map m
    end
  
    translated.join " AND "
  end

  def translate_service_characteristic_map(map)
    case map.characteristic.datatype
    when 'bool'
      ((map.value == 'true') ? '' : 'Not ') + I18n.t(map.characteristic.name)
    when 'integer'
      I18n.t(map.characteristic.name) +
        ' ' + relationship_to_words(map.rel_code) +
        ' ' + map.value.to_s
    else
      I18n.t(map.characteristic.name)
    end
  end
  
end
