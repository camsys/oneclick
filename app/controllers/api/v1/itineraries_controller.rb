module Api
  module V1
    class ItinerariesController < Api::V1::ApiController
      include CsHelpers

      #Todo: Ensure that trip matches the itinerary
      #Todo: Gracefully handle errors

      # passed an array of itineraries to be selected
      def select
        #Get the itineraries
        itineraries = []

        params[:select_itineraries].each do |itin|
          itinerary = Itinerary.find(itin['itinerary_id'].to_i)
          itineraries.append(itinerary)
          if itin['trip_id']
            trip = Trip.find(itin['trip_id'].to_i)
          else
            trip = itinerary.trip_part.trip
          end
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

        user_profile = params[:user_profile]
        if user_profile
          @traveler.update_profile user_profile
        end

        #Unpack params
        modes = params['modes'] || ['mode_transit', 'mode_paratransit', 'mode_taxi', 'mode_ride_hailing']
        trip_parts = params[:itinerary_request]
        purpose = params[:trip_purpose]
        trip_token = params[:trip_token]
        optimize = params[:optimize]
        max_walk_miles = params[:max_walk_miles]
        max_bike_miles = params[:max_bike_miles] # Miles
        max_walk_seconds = params[:max_walk_seconds] # Seconds
        walk_mph = params[:walk_mph] || (@traveler.walking_speed ? @traveler.walking_speed.value : 3.0)

        #Assign Meta Data
        trip = Trip.new
        trip.creator = @traveler
        trip.user = @traveler
        trip.trip_purpose_raw = purpose
        trip.trip_purpose = TripPurpose.find_by(code: purpose)
        trip.desired_modes = Mode.where(code: modes)

        trip.token = trip_token
        trip.optimize = optimize || "TIME"
        trip.max_walk_miles = max_walk_miles
        trip.max_walk_seconds = max_walk_seconds
        trip.walk_mph = walk_mph
        trip.num_itineraries = (params[:num_itineraries] || 3).to_i
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
        relevant_purposes = []
        relevant_characteristics = []

        #Build the trip_parts (i.e., segments)
        trip_parts.each do |trip_part|
          # Create the outbound trip part
          tp = TripPart.new
          tp.trip = trip

          tp.sequence = trip_part[:segment_index]
          tp.is_depart = (trip_part[:departure_type].downcase == 'depart')

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

          my_itins = Itinerary.where(trip_part: tp)
          #my_itins = tp.itineraries
          my_itins.each do |itin|
            Rails.logger.info("ITINERARY NUMBER : " + itin.id.to_s)
          end

          Rails.logger.info('Trip part ' + tp.id.to_s + ' generated ' + tp.itineraries.count.to_s + ' itineraries')
          Rails.logger.info(tp.itineraries.inspect)
          #Append data for API
          my_itins.each do |itinerary|
            i_hash = itinerary.as_json
            i_hash[:segment_index] = itinerary.trip_part.sequence
            i_hash[:start_location] = itinerary.trip_part.trip.origin.build_place_details_hash
            i_hash[:end_location] = itinerary.trip_part.trip.destination.build_place_details_hash
            i_hash[:prebooking_questions] = itinerary.prebooking_questions
            i_hash[:bookable] = itinerary.is_bookable?
            i_hash[:user_registered] = itinerary.is_registered?
            i_hash[:product_id] = itinerary.product_id #Used for Uber
            if itinerary.service
              relevant_purposes += itinerary.service.purposes_hash
              relevant_characteristics += itinerary.service.characteristics_hash
              i_hash[:schedule] = itinerary.service.schedule_hash
              i_hash[:service_name] = itinerary.service.name
              i_hash[:phone] = itinerary.service.phone
              i_hash[:logo_url]= logo_url_helper(itinerary)
              i_hash[:url] = itinerary.service.url
              i_hash["hidden"] ||= i_hash["missing_information"] # Set hidden to true if missing information about user characteristics
              comment = itinerary.service.comments.where(locale: "en").first
              if comment
                i_hash[:comment] = comment.comment
              end
            else
              i_hash[:service_name] = ""
            end

            if itinerary.discounts
              i_hash[:discounts] = JSON.parse(itinerary.discounts)
            end

            #Add Service Names to Legs
            unless itinerary.legs.nil?
              yaml_legs = YAML.load(itinerary.legs)
              yaml_legs.each do |leg|
                unless leg['agencyId'].nil?
                  service = Service.where(external_id: leg['agencyId']).first
                  unless service.nil?
                    leg['serviceName'] = service.name
                  else
                    leg['serviceName'] = leg['agencyName'] || leg['agencyId']
                  end
                end
              end
              itinerary.legs = yaml_legs.to_yaml
              itinerary.save
            end

            if itinerary.legs
              i_hash[:json_legs] = (YAML.load(itinerary.legs)).as_json
            else
              i_hash[:json_legs] = nil
            end

            final_itineraries.append(i_hash)

          end

        end

        # All accommodations are relevant.  If a service does not offer an accommodation it should still show up in the list.
        relevant_accommodations = Accommodation.all.collect{ |a| {name: TranslationEngine.translate_text(a.name), code: a.code, note: TranslationEngine.translate_text(a.note)}}

        Rails.logger.info('Sending ' + final_itineraries.count.to_s + ' in the response.')
        render json: {trip_id: trip.id, trip_token: trip.token, purposes: relevant_purposes.uniq, characteristics: relevant_characteristics.uniq, accommodations: relevant_accommodations, itineraries: final_itineraries}

      end

      def book

        booking_request = params[:booking_request]
        booked_itineraries = []

        booking_request.each do |itinerary_hash|
          itinerary = Itinerary.find(itinerary_hash[:itinerary_id].to_i)

          ecolane_booking = EcolaneBooking.where(itinerary: itinerary).first_or_create

          #Set Companions
          ecolane_booking.assistant = yes_or_no(itinerary_hash[:assistant].to_bool || itinerary_hash[:escort].to_bool)
          ecolane_booking.children = itinerary_hash[:children].to_i
          ecolane_booking.companions = itinerary_hash[:companions].to_i
          ecolane_booking.other_passengers = itinerary_hash[:other_passengers].to_i
          ecolane_booking.note_to_driver = itinerary_hash[:note]
          ecolane_booking.save

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
            status  = bi.status
            bi.trip_part.unselect
            bi.selected = true
            bi.save
            puts 'Itinerary ' + bi.id.to_s + " has been booked and marked as selected. "

            negotiated_pu_time = bi.negotiated_pu_time
            if negotiated_pu_time.nil?
              wait_start = nil
              wait_end = nil
            else
              #Create +/- fifteen minute window around pickup time
              wait_start = (negotiated_pu_time.to_time - 15*60).iso8601
              wait_end = (negotiated_pu_time.to_time + 15*60).iso8601
            end

            negotiated_do_time = bi.negotiated_do_time.nil? ? bi.end_time : bi.negotiated_do_time
            negotiated_duration = negotiated_do_time - negotiated_pu_time
            negotiated_do_time = negotiated_do_time.iso8601
            results_array.append({trip_id: bi.trip_part.trip.id, itinerary_id: bi.id, booked: true, confirmation_id: bi.booking_confirmation, wait_start: wait_start, wait_end: wait_end, arrival: negotiated_do_time, message: nil, negotiated_duration: negotiated_duration })

          end

          # If staff email updates are configured, send one for the booked trip.
          booked_provider = booked_itineraries.first.service.provider
          if booked_provider && booked_provider.send_booking_emails
            email_for_update = booked_provider.admin_user ? booked_provider.admin_user.email : nil
            UserMailer.booked_trip_update_email(email_for_update, Trip.find(booked_itineraries.first.trip_part.trip.id), "Ecolane").deliver
          end

        #Build Failure Response
        else
          booking_request.each do |i|
            results_array.append({trip_id: i[:trip_id], itinerary_id: i[:itinerary_id], booked: false, confirmation: nil, wait_start: nil, wait_end: nil, arrival: nil, message: nil})
          end
        end

        render json: {booking_results: results_array}

      end

      def cancel
        bookingcancellation_request = params[:bookingcancellation_request]

        results_array = []
        bookingcancellation_request.each do |bc|

          if bc[:itinerary_id]
            itinerary = Itinerary.find(bc[:itinerary_id].to_i)
            booking_confirmation = itinerary.booking_confirmation
            result = itinerary.cancel
          elsif bc[:booking_confirmation]
            booking_confirmation = bc[:booking_confirmation]
            itinerary = Itinerary.find_by(booking_confirmation: booking_confirmation)
            if itinerary #This itinerary was booked through the 1-Click. Mark it as unselected and canceled
              result = itinerary.cancel
            else #This itinerary was NOT booked through 1-Click. Cancel it Anyway.
              bs = BookingServices.new
              result = bs.cancel_external bc[:booking_confirmation], @traveler
            end
          end
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
          trip_to_email = itineraries.first
          trip = Trip.find(trip_to_email[:trip_id].to_i)

          if trip.scheduled_time > Time.now
            subject = "Your Upcoming Ride on " + trip.scheduled_time.strftime('%_m/%e/%Y').gsub(" ","")
          else
            subject = "Your Ride on " + trip.scheduled_time.strftime('%_m/%e/%Y').gsub(" ","")
          end
          UserMailer.user_trip_email([email_address], trip, subject, '', @traveler).deliver
        end

        render json: {result: 200}

      end


      def request_create_maps (trip)
        itins = trip.selected_itineraries
        itins.each do |itin|
          print_url = create_map_user_trip_itinerary_url(trip.user.id.to_s, trip.id.to_s, itin.id.to_s)
          Rails.logger.info "print_url is #{print_url}"
          PrintMapWorker.perform_async(print_url, itin.id)
        end
        return
      end

      def yes_or_no value
        value.to_bool ? 1 : 0
      end

    end #Itineraries Controller
  end #V1
end #API
