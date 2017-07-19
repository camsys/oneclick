module Api
  module V1
    class TripsController < Api::V1::ApiController

      def status_from_token
        #Get the itineraries
        trip_token = params[:trip_token]
        agency_token = params[:agency_token] || nil
        trip = Trip.where(token: trip_token, agency_token: agency_token).first
        get_trip_status trip

      end

      def details_from_token
        trip_token = params[:trip_token]
        agency_token = params[:agency_token] || nil
        trip = Trip.where(token: trip_token, agency_token: agency_token).first
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
          trip_json = trip.as_json
          trip_json[:origin] = trip.from_place.build_place_details_hash
          trip_json[:destination] = trip.to_place.build_place_details_hash
          hash = {status: {code: trip.status[:code], description: trip.status[:description]}, details: trip_json}
        else
          hash = {status: {code: '404', description: 'Trip Not Found'}, details: nil}
        end
        respond_with hash

      end

      def future_trips

        trips_hash = {}

        bs = BookingServices.new
        if @traveler
          trips_hash = @traveler.future_trips
        end

        respond_with trips_hash

      end

      def past_trips

        max_results = (params[:max_results] || 10).to_i

        trips_hash = {}

        bs = BookingServices.new
        if @traveler
          trips_hash = @traveler.past_trips(max_results)
        end

        respond_with trips_hash

      end

      def list
        trips_array = []
        @traveler.trips.selected.order(created_at: :desc)[0..19].each do |trip|
          trip_hash =  trip.attributes
          trip_hash[:from_place] = trip.from_place.nil? ? '' : trip.from_place.name
          trip_hash[:to_place] = trip.to_place.nil? ? ' ' : trip.to_place.name
          itineraries_array = []
          trip.selected_itineraries.each do |itinerary|
            itinerary_hash = itinerary.attributes
            mode = itinerary.mode
            itinerary_hash[:mode] = {name: TranslationEngine.translate_text(mode.name), code: mode.code}

            itinerary_hash[:segment_index] = itinerary.trip_part.sequence
            itinerary_hash[:start_location] = itinerary.trip_part.from_trip_place.build_place_details_hash
            itinerary_hash[:end_location] = itinerary.trip_part.to_trip_place.build_place_details_hash
            itinerary_hash[:prebooking_questions] = itinerary.prebooking_questions
            itinerary_hash[:bookable] = itinerary.is_bookable?
            itinerary_hash[:confirmation_id] = itinerary.booking_confirmation
            itinerary_hash[:requested_time] = itinerary.trip_part.scheduled_time.iso8601
            itinerary_hash[:requested_time_type] = itinerary.trip_part.is_depart ? 'depart' : 'arrive'
            itinerary_hash[:assistant] = itinerary.trip_part.assistant
            itinerary_hash[:children] = itinerary.trip_part.children
            itinerary_hash[:companions] = itinerary.trip_part.companions
            itinerary_hash[:other_passengers] = itinerary.trip_part.other_passengers
            itinerary_hash[:note] = itinerary.trip_part.note_to_driver
            itinerary_hash[:product_id] = itinerary.product_id #Used for Uber

            if itinerary.service
              i_hash[:service_name] = itinerary.service.name
              i_hash[:phone] = itinerary.service.phone
              i_hash[:logo_url]= itinerary.service.logo_url
              comment = itinerary.service.comments.where(locale: "en").first
              if comment
                i_hash[:comment] = comment.comment
              end
            else
              i_hash[:service_name] = ""
            end

            if itinerary.discounts
              itinerary_hash[:discounts] = JSON.parse(itinerary.discounts)
            end

            if itinerary.legs
              itinerary_hash[:json_legs] = (YAML.load(itinerary.legs)).as_json
            else
              itinerary_hash[:json_legs] = nil
            end

            if itinerary.negotiated_pu_time.nil?
              wait_start = nil
              wait_end = nil
            else
              #Create +/- fifteen minute window around pickup time
              wait_start = (itinerary.negotiated_pu_time - 15*60).iso8601
              wait_end = (itinerary.negotiated_pu_time + 15*60).iso8601
            end

            itinerary_hash[:wait_start] =  wait_start
            itinerary_hash[:wait_end] = wait_end
            itinerary_hash[:arrival] = itinerary.negotiated_do_time.nil? ? nil : itinerary.negotiated_do_time.iso8601


            itineraries_array.append(itinerary_hash)

          end
          trip_hash[:itineraries] = itineraries_array
          trips_array.append(trip_hash)
        end
        hash = {trips: trips_array}
        respond_with hash
      end

      def index
        list
      end

      def email
        email_address = params[:email_address]
        trip_id = params[:trip_id]
        booking_confirmations = params[:booking_confirmations]

        #Do the booking confirmations
        if booking_confirmations
          trip_hash = process_booking_confirmations(booking_confirmations)
          UserMailer.ecolane_trip_email([email_address], @traveler, trip_hash).deliver

        #Do the trip_id if booking confirmations is empty
        elsif trip_id
          trip = Trip.find(trip_id.to_i)
          UserMailer.user_trip_email([email_address], trip, '', @traveler).deliver
        end

        # Should probably add a case for if no params are passed.

        # Also should improve the JSON response to handle successfully and failed email calls`
        render json: {result: 200}

      end

      private

      # Helper function processes an array of booking confirmation numbers and returns a hash of trips
      def process_booking_confirmations booking_confirmations
        trip_hash = []
        bs = BookingServices.new
        user_service = @traveler.user_profile.user_services.first

        booking_confirmations.each do |booking_confirmation|

          raw_trip = bs.get_trip_details(user_service, booking_confirmation)
          trip = {}

          #Formatted Date
          date = raw_trip["order"]["pickup"]["date"]
          if date.kind_of?(Array)
            date = date.first
          end
          date = Date.strptime(date, "%Y-%m-%d")
          trip[:date] = date.strftime("%A, %B %e")

          #Times
          pickup = raw_trip["order"]["pickup"]["negotiated"]
          dropoff = raw_trip["order"]["dropoff"]["negotiated"]
          pickup = DateTime.parse(pickup)
          wait_start = pickup - 15.minutes
          wait_end = pickup + 15.minutes
          trip[:wait_start] = wait_start.strftime("%l:%M %P")
          trip[:wait_end] = wait_end.strftime("%l:%M %P")

          if dropoff
            dropoff = DateTime.parse(dropoff)
            days = (dropoff - wait_start).to_f
            hours = (days*24.0).floor
            minutes = (((days*24.0) - hours)*60.0).floor
            if hours > 0
              trip[:duration] = hours.to_s + " hours, " + minutes.to_s + " minutes"
            else
              trip[:duration] = minutes.to_s + " minutes"
            end
            trip[:dropoff] = dropoff.strftime("%l:%M %P")
          else
            trip[:duration] = ""
            trip[:dropoff] =  ""
          end

          #Cost
          cost = raw_trip["order"]["fare"]["client_copay"]
          cost = cost.to_f/100.0
          if cost > 0
            trip[:cost] = sprintf "$%.2f", cost
          else
            trip[:cost] = "Free"
          end

          #Confirmation
          trip[:confirmation] = raw_trip["order"]["id"]

          #Origin
          location = raw_trip["order"]["pickup"]["location"]
          trip[:origin] = location["street_number"].to_s + ' ' + location["street"].to_s + ', ' + location["city"].to_s + ', '  + location["state"].to_s

          #Destination
          location = raw_trip["order"]["dropoff"]["location"]
          trip[:destination] = location["street_number"].to_s + ' ' + location["street"].to_s + ', ' + location["city"].to_s + ', '  + location["state"].to_s

          trip_hash << trip
        end
        trip_hash
      end

    end
  end
end
