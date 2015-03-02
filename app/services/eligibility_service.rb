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
    missing_information_text_list = []
    missing_information_text = ''
    missing_info = []
    groups = service.service_characteristics.pluck(:group).uniq rescue []
    if groups.count == 0
      is_eligible = true
      min_match_score = 0
    end
    groups.each do |group|
      group_missing_information_text_list = []
      group_missing_information_text = ''
      group_missing_info = []
      group_match_score = 0
      group_eligible = true
      service_characteristic_maps = service.service_characteristics.where(group: group)

      service_characteristic_maps.each do |service_characteristic_map|
        service_requirement = service_characteristic_map.characteristic

        passenger_characteristic = user_profile.user_characteristics.where(
        characteristic: service_requirement || service_requirement.linked_characteristic).first

        #This passenger characteristic is not listed
        unless passenger_characteristic and not(passenger_characteristic.value.blank?)
          group_match_score += 0.25
          if service_requirement.code == 'age'
            if service_characteristic_map.rel_code == GT or service_characteristic_map.rel_code == GE
              group_missing_information_text_list << 'age_min' + service_characteristic_map.value.to_s
              group_missing_info << service_requirement.for_missing_info(service, group, service_requirement.code)
            elsif service_characteristic_map.rel_code == LT or service_characteristic_map.rel_code == LE
              group_missing_information_text_list << 'age_max' + service_characteristic_map.value.to_s
              group_missing_info << service_requirement.for_missing_info(service, group, service_requirement.code)
            end
          else
            group_missing_information_text_list << service_requirement.code + "_missing_info"
            group_missing_info << service_requirement.for_missing_info(service, group, service_requirement.code)
          end
          next
        end

        is_age_by_yob = false # whether age is calculated based on year_of_birth, also, if age == service_char.value
                              # in this case, we dont know whether eligible or not
        if service_requirement.code == 'age' and !service_characteristic_map.value.blank? and passenger_characteristic and passenger_characteristic.characteristic.code == 'age' and !passenger_characteristic.value.blank? and service_characteristic_map.value == passenger_characteristic.value
          dob_passenger_char = user_profile.user_characteristics.where( characteristic: passenger_characteristic.characteristic.linked_characteristic).first
          if !dob_passenger_char.value.blank? and dob_passenger_char.value.to_s.split('-').length <3
            is_age_by_yob =  true
            group_match_score += 0.25
            if service_characteristic_map.rel_code == GT or service_characteristic_map.rel_code == GE
              group_missing_information_text_list << 'persons ' + service_characteristic_map.value.to_s + ' years or older'
              group_missing_info << service_requirement.for_missing_info(service, group, service_requirement.code)
            elsif service_characteristic_map.rel_code == LT or service_characteristic_map.rel_code == LE
              group_missing_information_text_list << 'persons ' + service_characteristic_map.value.to_s + ' years or younger'
              group_missing_info << service_requirement.for_missing_info(service, group, service_requirement.code)
            end
          end
        end

        # Passenger does have a value for the characteristic, so test it
        unless is_age_by_yob
          begin
            unless passenger_characteristic.meets_requirement(service_characteristic_map)
              group_eligible = false
              break
            end
          rescue StandardError
            group_match_score += 0.25
            if service_characteristic_map.rel_code == GT or service_characteristic_map.rel_code == GE
              group_missing_information_text += 'persons ' + service_characteristic_map.value.to_s + ' years or older\n'
              group_missing_info << service_requirement.for_missing_info(service, group, 'age')
            elsif service_characteristic_map.rel_code == LT or service_characteristic_map.rel_code == LE
              group_missing_information_text += 'persons ' + service_characteristic_map.value.to_s + ' years or younger\n'
              group_missing_info << service_requirement.for_missing_info(service, group, 'age')
            end
            next
          end
        end
      end  # service_characteristic_maps.each do

      group_missing_information_text = group_missing_information_text_list.join(',')

      if group_eligible
        is_eligible = true
        # if group_match_score <= min_match_score
        missing_information_text_list << group_missing_information_text
        min_match_score = [min_match_score, group_match_score].min
        # end
        missing_info << group_missing_info
      end

    end # groups.each do

    missing_information_text = missing_information_text_list.join(':')

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
    accommodating_itineraries = []
    itineraries.each do |itinerary|
      service = itinerary['service']
      accommodations_maps = service.service_accommodations
      service_accommodations  = []
      accommodations_maps.each do |map|
        service_accommodations << map.accommodation
      end

      missing_service_count = (user_accommodations.count - (service_accommodations & user_accommodations).count)

      if missing_service_count == 0
        accommodating_itineraries << itinerary
      end

    end

    accommodating_itineraries

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
    Rails.logger.info "get_eligible_services_for_trip, starting count: #{itineraries.count}"
    itineraries = eligible_by_location(trip_part, itineraries)
    Rails.logger.info "get_eligible_services_for_trip, after location: #{itineraries.count}"
    itineraries = eligible_by_service_time(trip_part, itineraries)
    Rails.logger.info "get_eligible_services_for_trip, after service time: #{itineraries.count}"
    itineraries = eligible_by_advanced_notice_and_booking_cut_off_time(trip_part, itineraries)
    Rails.logger.info "get_eligible_services_for_trip, after advance notice: #{itineraries.count}"
    itineraries = eligible_by_trip_purpose(trip_part, itineraries)
    Rails.logger.info "get_eligible_services_for_trip, after trip purpose: #{itineraries.count}"
    itineraries = find_bookable_itineraries(trip_part, itineraries)
    Rails.logger.info "get_eligible_services_for_trip, after bookable: #{itineraries.count}"
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

      if user_service and not user_service.disabled and Oneclick::Application.config.allows_booking
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

      Rails.logger.info "eligible_by_location for service #{service.name rescue nil}"

      origin_point = factory.point(trip_part.from_trip_place.lon.to_f, trip_part.from_trip_place.lat.to_f)
      destination_point = factory.point(trip_part.to_trip_place.lon.to_f, trip_part.to_trip_place.lat.to_f)

      #Match Endpoint Area
      unless service.endpoint_area_geom.nil?
        unless service.endpoint_area_geom.geom.contains? origin_point or service.endpoint_area_geom.geom.contains? destination_point
          next
        end
      end

      #Match Coverage Area
      unless service.coverage_area_geom.nil?
        unless service.coverage_area_geom.geom.contains? origin_point and service.coverage_area_geom.geom.contains? destination_point
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
    eligible_itineraries = []
    wday = trip_part.trip_time.wday
    itineraries.each do |itinerary|
      service = itinerary['service']
      Rails.logger.info service.name
      unless service.nil?
        schedule = Schedule.where(day_of_week: wday, service_id: service.id).first
        if schedule.nil?
          itinerary['match_score'] += 1
          itinerary['date_mismatch'] = true
          Rails.logger.info 'date mismatch'
        else
          # puts "%-30s %-30s %s" % [Time.zone, planned_trip.trip_datetime, planned_trip.trip_datetime.seconds_since_midnight]
          # puts "%-30s %-30s %s" % [Time.zone, schedule.start_time, schedule.start_time.seconds_since_midnight]
          # puts "%-30s %-30s %s" % [Time.zone, schedule.end_time, schedule.end_time.seconds_since_midnight]
          unless trip_part.trip_time.seconds_since_midnight.between?(schedule.start_seconds,schedule.end_seconds)
            itinerary['match_score'] += 1
            itinerary['time_mismatch'] = true
            Rails.logger.info 'time mismatch'
          end
        end
      end

      if itinerary['date_mismatch'] != true && itinerary['time_mismatch'] != true
        eligible_itineraries << itinerary
      end
    end

    eligible_itineraries

  end

  def eligible_by_advanced_notice_and_booking_cut_off_time(trip_part, itineraries)
    eligible_itineraries = []
    itineraries.each do |itinerary|
      service = itinerary['service']
      unless service.nil?
        # get advanced notice days
        notice_days = 0
        notice_mins = service.advanced_notice_minutes
        max_advanced_mins = service.max_advanced_book_minutes
        max_advanced_days = 0
        if !notice_mins.blank?
          notice_days = notice_mins /(24*60).round
        end
        if !max_advanced_mins.blank?
          max_advanced_days = max_advanced_mins /(24*60).round
        end

        trip_created_wday = trip_part.created_at.wday

        # check if after booking_cut_off_time
        days_after_cut_off_time = 0
        booking_cut_off_time = service.booking_cut_off_times.where(day_of_week: trip_created_wday, service_id: service.id).first
        if !booking_cut_off_time.blank?
          cut_off_seconds = booking_cut_off_time.cut_off_seconds
          trip_created_seconds = trip_part.created_at.seconds_since_midnight

          if trip_created_seconds > cut_off_seconds
            days_after_cut_off_time = 1
          end
        end

        # compare if scheduled trip time is earlier than earliest allowable trip start time
        if trip_part.trip_time < (trip_part.created_at + (notice_days + days_after_cut_off_time).days).midnight
          itinerary['match_score'] += 0.01
          itinerary['too_late'] = true
        end

        if trip_part.trip_time > (trip_part.created_at + (max_advanced_days+1).days).midnight
          itinerary['match_score'] += 0.01
          itinerary['too_early'] = true
        end
      end

      if (itinerary['too_late'] != true && itinerary['too_early'] != true)
        eligible_itineraries << itinerary
      end
    end

    eligible_itineraries

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
