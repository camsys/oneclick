class BookingServices

  require 'indirizzo'

  ##### Constants ####
  AGENCY = {
      :ecolane => 0,
      :trapeze => 1
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
        parsed_address = get_number_and_street(origin.address1)
        origin_hash = {street_num: parsed_address[0], on_street: parsed_address[1], city: origin.city, state: origin.state, zip_code: origin.zip, lat: origin.lat, lon: origin.lon}

        destination = itinerary.trip_part.to_trip_place
        parsed_address = get_number_and_street(destination.address1)
        destination_hash = {street_num: parsed_address[0], on_street: parsed_address[1], city: destination.city, state: destination.state, zip_code: destination.zip, lat: destination.lat, lon: destination.lon}


        ts = TrapezeServices.new
        result = ts.pass_create_trip(trapeze_profile.endpoint, trapeze_profile.namespace, trapeze_profile.username, trapeze_profile.password, user_service.external_user_id,user_service.external_user_password, origin_hash, destination_hash, itinerary.start_time.seconds_since_midnight.to_i, itinerary.start_time.strftime("%Y%m%d"))
        result = result.to_hash

        booking_id = result[:envelope][:body][:pass_create_trip_response][:pass_create_trip_result][:booking_id]

        if booking_id.to_i == -1 #Failed to book
          return {trip_id: itinerary.trip_part.trip.id, itinerary_id: itinerary.id, booked: false, confirmation: nil, message: message}
        else
          itinerary.booking_confirmation = booking_id

          ### Get and Unpack Times
          times_hash = ts.get_estimated_times(trapeze_profile.endpoint, trapeze_profile.namespace, trapeze_profile.username, trapeze_profile.password, user_service.external_user_id, user_service.external_user_password, booking_id)
          unless times_hash[:neg_time].nil?
            itinerary.negotiated_pu_time = Chronic.parse((itinerary.trip_part.scheduled_time.to_date.to_s) + seconds_since_midnight_to_string(times_hash[:neg_time]))
          end

          message = result[:envelope][:body][:pass_create_trip_response][:validation][:item].first[:message]

          itinerary.save
          return {trip_id: itinerary.trip_part.trip.id, itinerary_id: itinerary.id, booked: true, negotiated_pu_time: itinerary.negotiated_pu_time, confirmation: booking_id, message: message}

        end

      else
        return {trip_id: itinerary.trip_part.trip.id, itinerary_id: itinerary.id, booked: false, negotiated_pu_time: nil, confirmation: nil, message: message}
    end

  end

  def cancel itinerary
    #return true is successful, false if not successful
    case itinerary.service.booking_profile
      when AGENCY[:ecolane]
        eh = EcolaneHelpers.new
        result = eh.cancel_itinerary self
        if result
          self.selected = false
          self.save
        end

      when AGENCY[:trapeze]
        user = itinerary.trip_part.trip.user
        user_service = UserService.find_by(user_profile: user.user_profile, service: itinerary.service)

        trapeze_profile = itinerary.service.trapeze_profile

        ts = TrapezeServices.new
        ts.cancel_trip(trapeze_profile.endpoint, trapeze_profile.namespace, trapeze_profile.username, trapeze_profile.password, user_service.external_user_id, user_service.external_user_password, itinerary.booking_confirmation)

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
          us.external_user_password = external_user_password
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
        return ts.pass_validate_client_password(trapeze_profile.endpoint, trapeze_profile.namespace, trapeze_profile.username, trapeze_profile.password, user_service.external_user_id, user_service.external_user_password)
    end
  end

  def get_number_and_street(street_address)
    parsable_address = Indirizzo::Address.new(street_address)
    return [parsable_address.number, parsable_address.street.first]
  end

  def seconds_since_midnight_to_string(seconds_since_midnight)
    seconds_since_midnight = seconds_since_midnight.to_i
    hour =seconds_since_midnight/3600
    minute = (seconds_since_midnight - (hour*3600))/60
    second = seconds_since_midnight - (hour*3600) - (minute*60)
    hour = (hour < 10) ? "0" + hour.to_s : hour.to_s
    return hour + ':' + minute.to_s + ":" + second.to_s
  end

end
