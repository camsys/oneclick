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
        ts.pass_create_trip_test(trapeze_profile.endpoint, trapeze_profile.namespace, trapeze_profile.username, trapeze_profile.password, user_service.external_user_id,user_service.external_user_password)
        return

      else
        return false
    end
  end

end
