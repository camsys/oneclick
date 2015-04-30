module Api
  module V1
    class ItinerariesController < Api::V1::ApiController

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
        #Move to a config.  API does not pass modes.
        modes = ['mode_paratransit', 'mode_taxi', 'mode_transit']

        #Unpack params
        trip_parts = params[:itinerary_request]
        purpose = params[:trip_purpose]
        trip_token = params[:trip_token]

        #Assign Meta Data
        trip = Trip.new
        trip.creator = @traveler
        trip.user = @traveler
        trip.trip_purpose = TripPurpose.where(code: purpose).first
        trip.desired_modes = Mode.where(code: modes)
        trip.token = trip_token
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

        final_itineraries = []

        #Build the trip_parts (i.e., segments)
        trip_parts.each do |trip_part|
          # Create the outbound trip part              ssss
          tp = TripPart.new
          tp.trip = trip



          tp.sequence = trip_part[:segment_index]
          tp.is_depart? == (trip_part[:departure_type] == 'depart')

          tp.scheduled_time = trip_part[:trip_time].to_datetime
          tp.scheduled_date = trip_part[:trip_time].to_date

          #Assign trip_places
          if tp.sequence == 0
            tp.from_trip_place = from_trip_place
            tp.to_trip_place = to_trip_place
          else
            tp.from_trip_place = to_trip_place
            tp.to_trip_place = from_trip_place
          end

          #Save Trip Part
          raise 'TripPart not valid' unless tp.valid?
          trip.trip_parts << tp

          #Seems redundant
          if tp.sequence == 0
            trip.scheduled_date = tp.scheduled_date
            trip.scheduled_time = tp.scheduled_time
            trip.save
          end

          #Build the itineraries
          tp.create_itineraries

          #Append data for API
          tp.itineraries.each do |itinerary|
            i_hash = itinerary.as_json
            i_hash[:segment_index] = itinerary.trip_part.sequence
            i_hash[:start_location] = itinerary.trip_part.from_trip_place.build_place_details_hash
            i_hash[:end_location] = itinerary.trip_part.to_trip_place.build_place_details_hash
            i_hash[:bookable] = itinerary.is_bookable?
            if itinerary.legs
              i_hash[:json_legs] = (YAML.load(itinerary.legs)).as_json
            else
              i_hash[:json_legs] = nil
            end
            final_itineraries.append(i_hash)
          end





          #Unpack and return the itineraries
          #MORE TO WRITE HERE
        end
        render json: {trip_id: trip.id, trip_token: trip.token, itineraries: final_itineraries}

      end

      def book
        booking_request = params[:booking_request]
        booked_itineraries = []

        booking_request.each do |itinerary_hash|
          itinerary = Itinerary.find(itinerary_hash[:itinerary_id].to_i)
          result, message = itinerary.book

          if result
            booked_itineraries.append(itinerary)
          else
            booked_itineraries.each do |booked_itinerary|
              booked_itinerary.cancel
            end
            booked_itineraries = []
            break
          end
        end

        results_array = []
        #Build Success Response
        if booked_itineraries.count > 0
          booked_itineraries.each do |bi|
            results_array.append({trip_id: bi.trip_part.trip.id, itinerary_id: bi.id, success: true, confirmation_id: bi.booking_confirmation})
          end

        #Build Failure Response
        else
          booking_request.each do |i|
            results_array.append({trip_id: i[:trip_id], itinerary_id: i[:itinerary_id], success: false, confirmation_id: nil})
          end
        end

        render json: {booking_results: results_array}

      end

      def cancel
        bookingcancellation_request = params[:bookingcancellation_request]

        results_array = []
        bookingcancellation_request.each do |bc|
          itinerary = Itinerary.find(bc[:itinerary_id].to_i)
          booking_confirmation = itinerary.booking_confirmation
          result = itinerary.cancel
          results_array.append({trip_id: bc[:trip_id], itinerary_id: bc[:itinerary_id], success: result, confirmation_id: booking_confirmation})
        end

        render json: {cancellation_results: results_array}

      end

      #Itinerary email template is out of date.
      def email
        email_itineraries = params[:email_itineraries]

        email_itineraries.each do |email_itinerary|
          email_address = email_itinerary[:email_address]
          itineraries = email_itinerary[:itineraries]

          itineraries.each do |itinerary|
            itin = Itinerary.find(itinerary[:itinerary_id].to_i)
            trip = itin.trip_part.trip
            UserMailer.user_itinerary_email([email_address], trip, itin, 'SUBJECT', '')
          end
        end

        render json: {result: 200}

      end

    end #Itineraries Controller
  end #V1
end #API