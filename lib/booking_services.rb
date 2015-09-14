class BookingServices


  ##### Constants ####
  AGENCY = {
      :ecolane => 0,
      :trapeze => 1
  }

  def book itinerary

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

        message = result[:envelope][:body][:pass_create_trip_response][:validation][:item].first[:message]

        if booking_id.to_i == -1 #Failed to book
          return {trip_id: itinerary.trip_part.trip.id, itinerary_id: itinerary.id, booked: false, confirmation: nil, message: message}
        else
          itinerary.booking_confirmation = booking_id
          itinerary.save
          return {trip_id: itinerary.trip_part.trip.id, itinerary_id: itinerary.id, booked: true, confirmation: booking_id, message: message}

        end

      else
        return {trip_id: itinerary.trip_part.trip.id, itinerary_id: itinerary.id, booked: false, confirmation: nil, message: message}
    end

  end

  def cancel itinerary
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
        ts.pass_cancel_trip(trapeze_profile.endpoint, trapeze_profile.namespace, trapeze_profile.username, trapeze_profile.password, user_service.external_user_id, user_service.external_user_password, itinerary.booking_confirmation)
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
    end
  end

  def get_number_and_street(street_address)
    parsable_address = Indirizzo::Address.new(street_address)
    return [parsable_address.number, parsable_address.street.first]
  end

end
