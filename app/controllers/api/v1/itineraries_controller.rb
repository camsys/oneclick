module Api
  module V1
    class ItinerariesController < ApplicationController
      respond_to :json
      require 'json'

      #Todo: Ensure that trip matches the itinerary
      #Todo: Gracefully handle errors

      #passed an array of itineraries to be selected
      def select
        #Get the itineraries
        itineraries = []

        params[:select_itineraries].each do |itin|
          itinerary = Itinerary.find(itin['itinerary_id'].to_i)
          itineraries.append(itinerary)
          trip = Trip.find(itin['trip_id'].to_i)
          trip.unselect_all
        end

        #Select these itineraries
        itineraries.each do |itinerary|
          itinerary.update_attribute :selected, true
        end

        render json: {result: 200}

      end

      #Post details on a trip, create/save the itineraries, and return them as json
      def plan

        #Missing from API Spec
        purpose = TripPurpose.first
        modes = ['mode_paratransit', 'mode_taxi', 'mode_transit']

        #Not built yet
        user = create_guest_user

        #Unpack params
        trip_parts = params[:itinerary_request]

        #Assign Meta Data
        trip = trip.new
        trip.creator = user
        trip.user = user
        trip.trip_purpose = purpose
        trip.desired_modes = Mode.where(code: modes)
        trip.save

        #Build the trip_parts (i.e., segments)
        trip_parts.each do |trip_part|
          # Create the outbound trip part
          trip_part = TripPart.new
          trip_part.trip = trip
          trip_part.sequence = trip_part[:segment_index]

          trip_part.is_depart? = (trip_part[:departure_type] == 'depart')


          #Seems redundant
          trip_part.scheduled_time = trip_part[:departure].to_datetime
          trip_part.scheduled_date = trip_part[:departure].to_date

          #TTHIS THIS THIS THIS
          trip_part.from_trip_place = from_place
          trip_part.to_trip_place = to_place
          #THIS THIS THIS THIS

          raise 'TripPart not valid' unless trip_part.valid?
          trip.trip_parts << trip_part


          #Seems redundant
          if trip_part.sequence == 0
            trip.scheduled_date = trip_part.scheduled_date
            trip.scheduled_time = trip_part.scheduled_time
          end

          #Build the itineraries
          trip.create_itineraries

          #Unpack and return the itineraries

        end

      end


    end
  end
end