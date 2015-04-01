module Api
  module V1
    class ItinerariesController < ApplicationController
      respond_to :json
      require 'json'

      #passed an array of itineraries to be selected
      def select

        #Get the itineraries
        itineraries = []
        params[:select_itineraries].each do |itin|
          itinerary = Itinerary.find(itin['itinerary_id'])
          itineraries.append(itinerary)
        end

        #Unselect any previously selected itineraries
        trip = itineraries.first.trip_part.trip
        trip.unselect_all

        #Select these itineraries
        itineraries.each do |itinerary|
          itinerary.update_attribute :selected, true
        end

        respond_with { head :no_content }

      end

    end
  end
end