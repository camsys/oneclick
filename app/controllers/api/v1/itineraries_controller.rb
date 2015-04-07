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

        #Build the Trip Places
        from_trip_place = TripPlace.new
        to_trip_place = TripPlace.new
        from_trip_place.trip = trip
        to_trip_place.trip = trip
        from_trip_place.sequence = 0
        to_trip_place.sequence = 1
        first_part = (trip_parts.select { |part| part[:segment_index] == 0}).first
        from_trip_place.from_place_details first_part[:start_location]
        to_trip_place.from_place_details first_part[:end_location]
        from_trip_place.save
        to_trip_place.save

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

          #Assign trip_places
          if trip_part.sequence == 0
            trip_part.from_trip_place = from_trip_place
            trip_part.to_trip_place = to_trip_place
          else
            trip_part.from_trip_place = to_trip_place
            trip_part.to_trip_place = from_trip_place
          end

          #Save Trip Part
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
          #MORE TO WRITE HERE
        end

      end

    end
  end
end