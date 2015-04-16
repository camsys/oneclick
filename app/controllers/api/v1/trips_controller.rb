module Api
  module V1
    class TripsController < Api::V1::ApiController

      def status_from_token
        #Get the itineraries
        trip_token = params[:trip_token]
        trip = Trip.where(token: trip_token).first
        get_trip_status trip

      end

      def details_from_token
        trip_token = params[:trip_token]
        trip = Trip.where(token: trip_token).first
        get_trip_details trip
      end

      def status
        trip_id = params[:id].to_i
        trip = Trip.find(trip_id)
        get_trip_status trip
      end

      def details
        trip_id = params[:id].to_i
        trip = Trip.find(trip_id)
        get_trip_details trip
      end


      def get_trip_status trip

        if trip
          hash = {trip_status_report: {trip_token: trip.token, trip_id: trip.id, code: trip.status[:code], description: trip.status[:description]}}
        else
          hash = {trip_status_report: {trip_token: nil, trip_id: nil, code: "404", description: "Trip not found."}}
        end

        respond_with hash

      end

      def get_trip_details trip


        # This is a stub.
        # More details will be added as-needed.
        if trip
          hash = {status: {code: trip.status[:code], description: trip.status[:description]}, details: trip}
        else
          hash = {status: {code: '404', description: 'Trip Not Found'}, details: nil}
        end
        respond_with hash

      end
    end
  end
end