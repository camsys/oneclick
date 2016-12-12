module Api
  module V1
    class TripPurposesController < Api::V1::ApiController

      def index
        bs = BookingServices.new
        service = nil
        #See if the @traveler is registered to book with a service
        user_service = nil
        if @traveler
          user_service = UserService.where(user_profile_id: @traveler.user_profile).first
        end

        #If the user is registered with a service, use his/her trip purposes
        if user_service

          Rails.logger.info("User is Registered")

          service = user_service.service
          begin
            trip_purposes = bs.get_purposes(@traveler.user_profile.user_services.first).keys
          rescue Exception=>e
            trip_purposes = []
          end
        #If the user is a guest, use a generic list of purposes
        else
          Rails.logger.info("No user service")
          origin = params[:geometry]
          lat = origin[:location][:lat]
          lng = origin[:location][:lng]

          booking_services = Service.where("fare_user <> ?", "")

          booking_services.each do |booking_service|
            if booking_service.primary_coverage_contains?(lat,lng)
              service = booking_service
              break
            end
          end


          default_trip_purpose = nil
          if service
            unless service.ecolane_profile.nil? && service.ecolane_profile.system.nil?
              trip_purposes = bs.get_dummy_trip_purposes(service)
            end

            if service.ecolane_profile
              default_trip_purpose = service.ecolane_profile.default_trip_purpose
            end
          end

        end
        Rails.logger.info("Trip Purposes:")
        Rails.logger.info(trip_purposes)

        #Append extra information to Trip Purposes Array
        purposes = []
        index =  0
        trip_purposes.each do |tp|
          purposes.append({name: tp, code: tp, sort_order: index})
          index+=1
        end

        #Append extra information to Top Trip Purposes Array
        top_trip_purposes = bs.get_top_purposes(trip_purposes).keys
        top_purposes = []
        index =  0
        top_trip_purposes.each do |tp|
          top_purposes.append({name: tp, code: tp, sort_order: index})
          index+=1
        end

        hash = {top_trip_purposes: top_purposes, trip_purposes: purposes, default_trip_purpose: default_trip_purpose}
        render json: hash

      end

      def list
        index
      end

    end
  end
end
