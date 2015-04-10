module Api
  module V1
    class TripsController < ApplicationController
      respond_to :json
      require 'json'

      def status
        #Get the itineraries
        trip_token = params[:trip_token]
        trip = Trip.where(token: trip_token).first

        if trip
          hash = {trip_status_report: {trip_token: trip_token, code: trip.status[:code], description: trip.status[:description]}}
        else
          hash = {trip_status_report: {trip_token: trip_token, code: "404", description: "Trip not found."}}
        end

        respond_with hash

      end

      def details
        trip_token = params[:trip_token]
        trip = Trip.where(token: trip_token).first

        # This is a stub.
        # More details will be added as-needed.
        hash = {status: {code: trip.status[:code], description: trip.status[:description]}, details: trip}
        respond_with hash

      end

    end
  end
end