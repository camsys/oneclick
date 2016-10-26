class BookingServices

  require 'street_address'
  include ActionView::Helpers::NumberHelper

  ##### Constants ####
  AGENCY = {
      :ecolane => 0,
      :trapeze => 1,
      :ridepilot => 2
  }

  def book itinerary

    if itinerary.is_booked?
      return {trip_id: itinerary.trip_part.trip.id, itinerary_id: itinerary.id, booked: false, confirmation: nil, message: "This itinerary is already booked."}
    end

    case itinerary.service.booking_profile

      when AGENCY[:ecolane]
        eh = EcolaneHelpers.new
        return eh.book_itinerary itinerary

      when AGENCY[:trapeze]
        user = itinerary.trip_part.trip.user
        user_service = UserService.find_by(user_profile: user.user_profile, service: itinerary.service)

        trapeze_profile = itinerary.service.trapeze_profile

        origin = itinerary.trip_part.from_trip_place
        parsed_address = get_parsed_address(origin.raw_address.blank? ? origin.address1 : origin.raw_address)
        origin_hash = {street_no: parsed_address.number, on_street: parsed_address.street.to_s + ' ' + parsed_address.street_type.to_s, unit: origin.unit, city: origin.city, state: origin.state, zip_code: origin.zip, lat: origin.lat, lon: origin.lon}

        destination = itinerary.trip_part.to_trip_place
        parsed_address = get_parsed_address(destination.raw_address.blank? ? destination.address1 : destination.raw_address)
        destination_hash = {street_no: parsed_address.number, on_street: parsed_address.street.to_s + ' ' + parsed_address.street_type.to_s, unit: destination.unit, city: destination.city, state: destination.state, zip_code: destination.zip, lat: destination.lat, lon: destination.lon}


        ts = TrapezeServices.new
        result = ts.pass_create_trip(trapeze_profile.endpoint, trapeze_profile.namespace, trapeze_profile.username, trapeze_profile.password, trapeze_profile.para_service_id, user_service.external_user_id,user_service.user_password, origin_hash, destination_hash, itinerary.start_time.seconds_since_midnight.to_i, itinerary.end_time.seconds_since_midnight.to_i, trapeze_profile.booking_offset_minutes, itinerary.start_time.strftime("%Y%m%d"), itinerary.trip_part.booking_trip_purpose_id, itinerary.trip_part.is_depart, itinerary.trapeze_booking.passenger1_type, itinerary.trapeze_booking.passenger2_type, itinerary.trapeze_booking.passenger3_type, itinerary.trapeze_booking.fare1_type_id, itinerary.trapeze_booking.fare2_type_id, itinerary.trapeze_booking.fare3_type_id, itinerary.trapeze_booking.passenger1_space_type, itinerary.trapeze_booking.passenger2_space_type, itinerary.trapeze_booking.passenger3_space_type)
        result = result.to_hash

        booking_id = result[:envelope][:body][:pass_create_trip_response][:pass_create_trip_result][:booking_id]
        message = result[:envelope][:body][:pass_create_trip_response][:pass_create_trip_result][:message]

        Rails.logger.info result.ai

        if booking_id.to_i == -1 #Failed to book

          begin
            message= TranslationEngine.translate_text(:booking_failure_message)
            items = result[:envelope][:body][:pass_create_trip_response][:validation][:item]
            unless items.kind_of?(Array) #Check to see if this is an array or a single item
              message = items[:message]
            else
              items.each do |item|
                if item[:type] == 'error'
                  message = item[:message]
                  break
                end
              end
            end
          rescue
            message= TranslationEngine.translate_text(:booking_failure_message)
          end
          return {trip_id: itinerary.trip_part.trip.id, itinerary_id: itinerary.id, booked: false, confirmation: nil, fare: nil, message: message}
        else
          itinerary.booking_confirmation = booking_id
          fare = result[:envelope][:body][:pass_create_trip_response][:pass_create_trip_result][:fare_amount]
          itinerary.cost = fare.blank? ? nil : fare.to_f

          ### Get and Unpack Times
          times_hash = ts.get_estimated_times(trapeze_profile.endpoint, trapeze_profile.namespace, trapeze_profile.username, trapeze_profile.password, user_service.external_user_id, user_service.user_password, booking_id)
          unless times_hash[:neg_time].nil?
            itinerary.negotiated_pu_time = Chronic.parse((itinerary.trip_part.scheduled_time.to_date.to_s) + " " +  seconds_since_midnight_to_string(times_hash[:neg_time]))
            itinerary.negotiated_pu_window_start = Chronic.parse((itinerary.trip_part.scheduled_time.to_date.to_s) + " " +  seconds_since_midnight_to_string(times_hash[:neg_early]))
            itinerary.negotiated_pu_window_end = Chronic.parse((itinerary.trip_part.scheduled_time.to_date.to_s) + " " +  seconds_since_midnight_to_string(times_hash[:neg_late]))
            itinerary.start_time = itinerary.negotiated_pu_time
          end

          itinerary.save
          return {trip_id: itinerary.trip_part.trip.id, itinerary_id: itinerary.id, booked: true, negotiated_pu_time: (itinerary.negotiated_pu_time.blank? ? "n/a" : itinerary.negotiated_pu_time.strftime("%b %e, %l:%M %p")), negotiated_pu_window_start: (itinerary.negotiated_pu_window_start.blank? ? "n/a" : itinerary.negotiated_pu_window_start.strftime("%b %e, %l:%M %p")), negotiated_pu_window_end: (itinerary.negotiated_pu_window_end.blank? ? "n/a" : itinerary.negotiated_pu_window_end.strftime("%b %e, %l:%M %p")), confirmation: booking_id, fare: number_to_currency(itinerary.cost), message: message}

        end

      when AGENCY[:ridepilot]
        rs = RidepilotServices.new

        ridepilot_profile = itinerary.service.ridepilot_profile
        user = itinerary.trip_part.trip.user
        user_service = UserService.find_by(user_profile: user.user_profile, service: itinerary.service)

        origin = itinerary.trip_part.from_trip_place
        from_hash = origin.build_place_details_hash
        from = {address: from_hash, address_name: nil, note: nil, in_district: nil}

        destination = itinerary.trip_part.to_trip_place
        to_hash = destination.build_place_details_hash
        to = {address: to_hash, address_name: nil, note: nil, in_district: nil}

        ridepilot_booking = itinerary.ridepilot_booking
        result, body = rs.create_trip(ridepilot_profile.endpoint, ridepilot_profile.api_token, ridepilot_profile.provider_id, user_service.external_user_id, user_service.user_password, ridepilot_booking.trip_purpose_code, leg = itinerary.trip_part.sequence + 1, from, to, guests = ridepilot_booking.guests, attendants = ridepilot_booking.attendants, mobility_devices = ridepilot_booking.mobility_devices, itinerary.start_time.iso8601, itinerary.end_time.iso8601)
        if result
          itinerary.booking_confirmation = body["trip_id"]
          itinerary.negotiated_pu_time = itinerary.start_time
          ridepilot_booking.booking_status_code = body["status"]["code"]
          ridepilot_booking.booking_status_name = body["status"]["name"]
          ridepilot_booking.booking_status_message = body["status"]["message"]
          itinerary.save
          ridepilot_booking.save
          return {trip_id: itinerary.trip_part.trip.id, itinerary_id: itinerary.id, booked: true, negotiated_pu_time:  (itinerary.negotiated_pu_time.blank? ? "n/a" : itinerary.negotiated_pu_time.strftime("%b %e, %l:%M %p")), confirmation: body["trip_id"], fare: nil, message: body["status"]["code"], booking_status_message: ridepilot_booking.booking_status_message}
        else
          return {trip_id: itinerary.trip_part.trip.id, itinerary_id: itinerary.id, booked: false, negotiated_pu_time: nil, negotiated_pu_window_start: nil, negotiated_pu_window_end: nil, confirmation: nil, fare: nil, message: ""}
        end
      else
        return {trip_id: itinerary.trip_part.trip.id, itinerary_id: itinerary.id, booked: false, negotiated_pu_time: nil, negotiated_pu_window_start: nil, negotiated_pu_window_end: nil, confirmation: nil, fare: nil, message: ""}
    end

  end

  def cancel itinerary
    #return true is successful, false if not successful
    user = itinerary.trip_part.trip.user
    user_service = UserService.find_by(user_profile: user.user_profile, service: itinerary.service)

    case itinerary.service.booking_profile

      when AGENCY[:ecolane]
        eh = EcolaneHelpers.new
        result = eh.cancel_itinerary self
        if result
          self.selected = false
          self.save
        end

      when AGENCY[:trapeze]
        trapeze_profile = itinerary.service.trapeze_profile
        ts = TrapezeServices.new
        return ts.cancel_trip(trapeze_profile.endpoint, trapeze_profile.namespace, trapeze_profile.username, trapeze_profile.password, user_service.external_user_id, user_service.user_password, itinerary.booking_confirmation)

      when AGENCY[:ridepilot]
        ridepilot_profile = itinerary.service.ridepilot_profile
        rs = RidepilotServices.new
        result, body = rs.cancel_trip(ridepilot_profile.endpoint, ridepilot_profile.api_token, user_service.external_user_id, user_service.user_password, itinerary.booking_confirmation)
        return result

    end
  end

  def associate_user(service, user, external_user_id, external_user_password)
    case service.booking_profile
      when AGENCY[:ecolane]
        puts 'todo'
      when AGENCY[:trapeze]
        trapeze_profile = service.trapeze_profile
        ts = TrapezeServices.new
        result = ts.pass_validate_client_password(trapeze_profile.endpoint, trapeze_profile.namespace, trapeze_profile.username, trapeze_profile.password, external_user_id, external_user_password)
        if result
          us = UserService.where(service: service, user_profile: user.user_profile).first_or_initialize
          us.external_user_id = external_user_id
          us.user_password = external_user_password
          us.save
        end
        return result
      when AGENCY[:ridepilot]
        ridepilot_profile = service.ridepilot_profile
        rs = RidepilotServices.new
        result, body = rs.authenticate_customer(ridepilot_profile.endpoint, ridepilot_profile.api_token, ridepilot_profile.provider_id, external_user_id, external_user_password)
        if result
          us = UserService.where(service: service, user_profile: user.user_profile).first_or_initialize
          us.external_user_id = external_user_id
          us.user_password = external_user_password
          us.save
        end
        return result
    end
  end

  def check_association(service, user)
    user_service = UserService.find_by(service: service, user_profile: user.user_profile)
    if user_service.nil?
      return false
    end

    case service.booking_profile
      when AGENCY[:ecolane]
        return false
      when AGENCY[:trapeze]
        trapeze_profile = service.trapeze_profile
        ts = TrapezeServices.new
        return ts.pass_validate_client_password(trapeze_profile.endpoint, trapeze_profile.namespace, trapeze_profile.username, trapeze_profile.password, user_service.external_user_id, user_service.user_password)
      when AGENCY[:ridepilot]
        ridepilot_profile = service.ridepilot_profile
        rs = RidepilotServices.new
        result, body = rs.authenticate_customer(ridepilot_profile.endpoint, ridepilot_profile.api_token, ridepilot_profile.provider_id, user_service.external_user_id, user_service.user_password)
        return result
    end
  end

  def get_parsed_address(raw_address)
    return StreetAddress::US.parse(raw_address)
  end

  def seconds_since_midnight_to_string(seconds_since_midnight)
    seconds_since_midnight = seconds_since_midnight.to_i
    hour =seconds_since_midnight/3600
    minute = (seconds_since_midnight - (hour*3600))/60
    second = seconds_since_midnight - (hour*3600) - (minute*60)
    hour = (hour < 10) ? "0" + hour.to_s : hour.to_s
    return hour + ':' + minute.to_s + ":" + second.to_s
  end

  def get_purposes_from_itinerary(itinerary)
    service = itinerary.service
    user = itinerary.trip_part.trip.user
    user_service = UserService.find_by(service: service, user_profile: user.user_profile)


    if user_service.nil?
      return {}
    else
      return get_purposes(user_service)
    end

  end

  def get_purposes(user_service)

    if user_service.nil?
      return {}
    end

    service = user_service.service

    case service.booking_profile
      when AGENCY[:ecolane]
        return []
      when AGENCY[:trapeze]
        trapeze_profile = service.trapeze_profile
        ts = TrapezeServices.new
        purposes = ts.get_booking_purposes(trapeze_profile.endpoint, trapeze_profile.namespace, trapeze_profile.username, trapeze_profile.password, user_service.external_user_id, user_service.user_password)
        purpose_hash= {}
        purposes.each do |purpose|
          purpose_hash[purpose[:description]] = purpose[:booking_purpose_id]
        end

        return purpose_hash.sort.to_h

      when AGENCY[:ridepilot]
        ridepilot_profile = service.ridepilot_profile
        rs = RidepilotServices.new
        result, body = rs.trip_purposes(ridepilot_profile.endpoint, ridepilot_profile.api_token, ridepilot_profile.provider_id)
        purposes_hash = {}
        if result
          body["trip_purposes"].each do |purpose|
            purposes_hash[purpose["name"]] = purpose["code"]
          end
        end

        return purposes_hash.sort.to_h

    end
  end

  def get_passenger_types_from_itinerary(itinerary)

    user_service = UserService.find_by(service: itinerary.service, user_profile: itinerary.trip_part.trip.user.user_profile)
    return get_passenger_types(user_service)

  end

  def get_passenger_types(user_service)

    if user_service.nil?
      return {}
    end

    service = user_service.service

    case service.booking_profile
      when AGENCY[:ecolane]
        return {}
      when AGENCY[:trapeze]
        trapeze_profile = service.trapeze_profile
        ts = TrapezeServices.new
        passenger_types = ts.get_passenger_types(trapeze_profile.endpoint, trapeze_profile.namespace, trapeze_profile.username, trapeze_profile.password, user_service.external_user_id, user_service.user_password)
        passenger_types_hash = {}
        passenger_types.each do |passenger_type|
          passenger_types_hash[passenger_type[:description]] = passenger_type[:abbreviation] + "%%" + passenger_type[:fare_type_id]
        end
        return passenger_types_hash
    end

  end

  def get_space_types_from_itinerary(itinerary)
    service = itinerary.service
    user = itinerary.trip_part.trip.user
    user_service = UserService.find_by(service: service, user_profile: user.user_profile)

    return get_space_types(user_service)

  end

  def authenticate_provider_from_profile(booking_profile)
    service = booking_profile.service
    authenticate_provider(booking_profile.endpoint, booking_profile.api_token, booking_profile.provider_id, service.booking_profile)
  end

  def authenticate_provider(endpoint, api_token, provider_id, booking_profile)

    case booking_profile.to_i
      when AGENCY[:ridepilot]
        rp = RidepilotServices.new
        result, body = rp.authenticate_provider(endpoint, api_token, provider_id)
        return {authenticated: result, message: body["error"]}
    end
  end

  def get_space_types(user_service)

    if user_service.nil?
      return {}
    end

    service = user_service.service

    case service.booking_profile
      when AGENCY[:ecolane]
        return {}
      when AGENCY[:trapeze]
        trapeze_profile = service.trapeze_profile
        ts = TrapezeServices.new
        space_types = ts.get_space_types(trapeze_profile.endpoint, trapeze_profile.namespace, trapeze_profile.username, trapeze_profile.password, user_service.external_user_id, user_service.user_password)
        space_types_hash = {}
        space_types.each do |space_type|
          space_types_hash[space_type[:description]] = space_type[:abbreviation]
        end
        return space_types_hash
    end
  end

  def update_trip_status(itinerary)
    service = itinerary.service
    user = itinerary.trip_part.trip.user
    user_service = UserService.find_by(service: service, user_profile: user.user_profile)

    case service.booking_profile
      when AGENCY[:ridepilot]
        ridepilot_profile = service.ridepilot_profile
        ridepilot_booking = itinerary.ridepilot_booking
        rs = RidepilotServices.new
        result, body = rs.trip_status(ridepilot_profile.endpoint, ridepilot_profile.api_token, user_service.external_user_id, user_service.user_password, itinerary.booking_confirmation)
        if result
          itinerary.booking_confirmation = body["trip_id"]
          itinerary.negotiated_pu_time = itinerary.start_time
          ridepilot_booking.booking_status_code = body["status"]["code"]
          ridepilot_booking.booking_status_name = body["status"]["name"]
          ridepilot_booking.booking_status_message = body["status"]["message"]
          itinerary.save
          ridepilot_booking.save
          return {trip_id: itinerary.trip_part.trip.id, itinerary_id: itinerary.id, booked: true, negotiated_pu_time:  (itinerary.negotiated_pu_time.blank? ? "n/a" : itinerary.negotiated_pu_time.strftime("%b %e, %l:%M %p")), confirmation: body["trip_id"], fare: nil, message: body["status"]["code"], booking_status_message: ridepilot_booking.booking_status_message}
        else
          return {trip_id: itinerary.trip_part.trip.id, itinerary_id: itinerary.id, booked: false, negotiated_pu_time: nil, negotiated_pu_window_start: nil, negotiated_pu_window_end: nil, confirmation: nil, fare: nil, message: ""}
        end
    end
  end

end
