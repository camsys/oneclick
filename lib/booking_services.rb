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

        ts = TrapezeServices.new
        result = ts.pass_create_trip_test(trapeze_profile.endpoint, trapeze_profile.namespace, trapeze_profile.username, trapeze_profile.password, user_service.external_user_id,user_service.external_user_password)
        result = result.to_hash

        booking_id = result[:envelope][:body][:pass_create_trip_response][:pass_create_trip_result][:booking_id]

        puts result.ai

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

end
