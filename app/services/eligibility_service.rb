class EligibilityService
  include EligibilityOperators

  def get_eligible_services_for_traveler(user_profile, trip_part=nil, return_with=:itinerary)

    #Check to see if this user is registered to book with anyone.
    #If this user is registered to book, we only care about the services that he/she can book with
    user_services = user_profile.user_services


    if user_services.count > 0 and Oneclick::Application.config.restrict_results_registered_services
      all_services = []
      user_services.each do |us|
        if us.service.active?
          all_services << us.service
        end
      end
    elsif user_profile.user.api_guest? and Oneclick::Application.config.restrict_services_to_origin_county
      all_services = service_from_trip_part trip_part
    else
      all_services = Service.paratransit.active
    end

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
    user_profile.user.clear_stale_answers
    tp = TripPlanner.new
    min_match_score = Float::INFINITY
    itinerary = nil
    is_eligible = false
    missing_information = false
    missing_information_text_list = []
    missing_information_text = ''
    missing_info = []

    #TODO Refactor this: Groups are no longer used.  The Group is actualy just the service_characteritsic id. So every characteristic is guaranteed to be in a different group
    groups = service.service_characteristics.pluck(:id).uniq rescue []

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
      service_characteristics = service.service_characteristics.where(id: group)

      service_characteristics.each do |service_characteristic|
        characteristic = service_characteristic.characteristic
        passenger_characteristic = user_profile.user_characteristics.find_by(characteristic: characteristic)
        #This passenger characteristic is not listed
        if passenger_characteristic.nil?
          group_match_score += 0.25
          group_missing_information_text_list << characteristic.code + "_missing_info"
          group_missing_info << characteristic.for_missing_info(service, group, characteristic.code)
          next
        end

        unless passenger_characteristic.value
          group_eligible = false
          break
        end

      end  # service_characteristic_maps.each do

      group_missing_information_text = group_missing_information_text_list.join(',')

      if group_eligible
        is_eligible = true
        missing_information_text_list << group_missing_information_text
        min_match_score = [min_match_score, group_match_score].min
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
    end

    itinerary = tp.convert_paratransit_itineraries(service, min_match_score, missing_information, missing_information_text)

    unless is_eligible
      itinerary['hidden'] = true
    end

    case return_with
    when :itinerary
      return itinerary
    when :missing_info
      return missing_info.flatten
    end
  end

  def get_accommodating_services_for_traveler(itineraries, user_profile)

    if user_profile.nil?
      return itineraries
    end

    user = user_profile.user

    user_needs = user.user_accommodations.where(value: "true").pluck(:accommodation_id)

    itineraries.each do |itin|
      service = itin["service"]
      service_provides = service.service_accommodations.where(active: "true").pluck(:accommodation_id)
      #The line below checks to see if all the elements in the user_needs array are contained in the service_provides array
      if not (user_needs - service_provides).blank?
        itin["hidden"] = true
      end
    end

    return itineraries

  end

  def get_accommodating_and_eligible_services_for_traveler(trip_part=nil)

    user_profile = trip_part.trip.user.user_profile unless trip_part.nil?

    if user_profile.nil? #TODO:  Need to update to handle anonymous users.  This currently only works with user logged in.
      return []
    end

    Rails.logger.debug "Get eligible services"
    eligible = get_eligible_services_for_traveler(user_profile, trip_part)
    accommodating = get_accommodating_services_for_traveler(eligible, user_profile)
    return accommodating
  end

  def remove_ineligible_itineraries(trip_part, itineraries)
    Rails.logger.info "remove_ineligible_itineraries, starting count: #{itineraries.count}"
    itineraries = eligible_by_location(trip_part, itineraries)
    Rails.logger.info "remove_ineligible_itineraries, after location: #{itineraries.count}"
    itineraries = eligible_by_service_time(trip_part, itineraries)
    Rails.logger.info "remove_ineligible_itineraries, after service time: #{itineraries.count}"
    itineraries = eligible_by_advanced_notice_and_booking_cut_off_time(trip_part, itineraries)
    Rails.logger.info "remove_ineligible_itineraries, after advance notice: #{itineraries.count}"
    itineraries = eligible_by_trip_purpose(trip_part, itineraries)
    Rails.logger.info "remove_ineligible_itineraries, after trip purpose: #{itineraries.count}"
    itineraries = find_bookable_itineraries(trip_part, itineraries)
    Rails.logger.info "remove_ineligible_itineraries, after bookable: #{itineraries.count}"
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

  # Returns the subset of the given itinerary hashes that are eligible by location based on the trip part
  def eligible_by_location(trip_part, itineraries)
    itineraries.select do |itinerary|
      service = itinerary['service']
      if service
        test = service.is_valid_for_trip_area(trip_part)
        puts "#{service.name} is #{"NOT " unless test}eligible by location"
        test
      else
        false
      end
    end
  end

  def eligible_by_trip_purpose(trip_part, itineraries)

    #If this trip not specify a specifc purpose, return all itineraries
    #It's basically saying "Show me all services, I don't want to filter by purpose"
    if trip_part.trip.trip_purpose.nil?
      return itineraries
    end

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

  # Returns an array of itineraries eligible by schedule
  def eligible_by_service_time(trip_part, itineraries)
    # For each itinerary passed, identify service and its schedules
    # Check if the trip part is eligible for any of these schedules; select only those itineraries for which this is true
    itineraries.select { |itin| trip_part.valid_for_service_time?(itin['service']) }
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

      puts "ITINERARY in ADVANCE NOTICE: ", itinerary.ai

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
      ((map.value == 'true') ? '' : 'Not ') + TranslationEngine.translate_text(map.characteristic.name)
    when 'integer'
      TranslationEngine.translate_text(map.characteristic.name) +
        ' ' + relationship_to_words(map.rel_code) +
        ' ' + map.value.to_s
    else
      TranslationEngine.translate_text(map.characteristic.name)
    end
  end

  #For guest api users, don't consider every service,  Only consider the service that covers their origin
  def service_from_trip_part trip_part
    county = trip_part.trip.origin.county || trip_part.trip.origin.get_county
    service = BookingServices.new.county_to_service(county)
    return service ? [service] : []
  end

end
