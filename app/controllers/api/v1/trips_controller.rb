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
          hash = {status: trip.status}
        else
          hash = {status: 404}
        end

        respond_with hash

      end

    end
  end
end