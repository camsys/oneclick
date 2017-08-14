module Export
  class BookingController < Export::ExportApiController
    
    def user_booking_profiles
      render json: UserService.all.map { |us| UserServiceSerializer.new(us).serializable_hash }

    end
    
    def service_booking_profiles
      render json: { service_booking_profiles: [] }
    end
    
    def trip_bookings
      render json: { trip_bookings: [] }
    end
    
  end
end
