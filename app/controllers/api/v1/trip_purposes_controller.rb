module Api
  module V1
    class TripPurposesController < Api::V1::ApiController

      def index
        eh = EcolaneHelpers.new

        service = nil
        #See if the @traveler is registered to book with a service

        user_service = nil
        if @traveler
          user_service = UserService.where(user_profile_id: @traveler.user_profile).first
        end

        if user_service

          service = user_service.service
          begin
            trip_purposes = eh.get_trip_purposes_from_traveler(@traveler)
          rescue Exception=>e
            Honeybadger.notify(
                :error_class   => "Trip Purposes Failure #1",
            )
            trip_purposes = []
          end
        else
          origin = params[:geometry]
          lat = origin[:location][:lat]
          lng = origin[:location][:lng]

          booking_services = Service.where("fare_user <> ?", "")

          booking_services.each do |booking_service|
            if booking_service.endpoint_contains?(lat,lng)
              service = booking_service
              break
            end
          end

          if service
            unless service.booking_system_id.nil?
              begin
                trip_purposes = eh.get_trip_purposes_from_customer_number(service.fare_user, service.booking_system_id)
              rescue Exception=>e
                Honeybadger.notify(
                    :error_class   => "Trip Purposes Failure #2",
                )
                trip_purposes = []
              end
            end
          end

        end

        purposes = []
        index =  0
        trip_purposes.each do |tp|
          purposes.append({name: tp, code: tp, sort_order: index})
          index+=1
        end

        hash = {trip_purposes: purposes}
        render json: hash

      end

      def list
        index
      end

    end
  end
end