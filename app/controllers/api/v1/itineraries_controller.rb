module Api
  module V1
    class ItinerariesController < Api::V1::ApiController
      include MapHelper, ItineraryHelper
      require 'benchmark'

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

        total_legs_stuff  = 0

        itins_loop_start = nil
        start_phase_1 = Time.now



        #Unpack params
        modes = params['modes'] || ['mode_transit']
        trip_parts = params[:itinerary_request]
        purpose = params[:trip_purpose]
        trip_token = params[:trip_token]
        optimize = params[:optimize]
        max_walk_miles = params[:max_walk_miles]
        max_bike_miles = params[:max_bicycle_miles] # Miles
        max_walk_seconds = params[:max_walk_seconds] # Seconds
        walk_mph = params[:walk_mph] || (@traveler.walking_speed ? @traveler.walking_speed.value : 3.0)
        min_transfer_time = params[:min_transfer_time]
        max_transfer_time = params[:max_transfer_time]
        banned_routes = params[:banned_routes]
        preferred_routes = params[:preferred_routes]
        source_tag = params[:source_tag]

        #Assign Meta Data
        trip = Trip.new
        trip.creator = @traveler
        trip.user = @traveler
        trip.trip_purpose_raw = purpose
        trip.desired_modes_raw = modes
        puts 'Reading Modes'
        benchmark { trip.desired_modes = Mode.where(code: modes) }

        trip.token = trip_token
        trip.optimize = optimize || "TIME"
        trip.max_walk_miles = max_walk_miles
        trip.max_walk_seconds = max_walk_seconds
        trip.walk_mph = walk_mph
        trip.max_bike_miles = max_bike_miles
        trip.num_itineraries = (params[:num_itineraries] || 3).to_i
        trip.min_transfer_time = min_transfer_time.nil? ? nil : min_transfer_time.to_i
        trip.max_transfer_time = max_transfer_time.nil? ? nil : max_transfer_time.to_i
        trip.source_tag = source_tag
        puts "trip.save"
        #benchmark { trip.save }

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
        puts "from_trip_place.save"
        #benchmark { from_trip_place.save }
        puts "to_trip_place.save"
        #benchmark { to_trip_place.save }

        final_itineraries = []

        start_phase_2 = nil

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

          #If not feed ID is sent, assume the first feed id.  It's almost always 1
          first_feed_id = Oneclick::Application.config.first_feed_id || TripPlanner.new.get_first_feed_id

          #Set Banned Routes
          unless banned_routes.blank?
            banned_routes_string = ""
            banned_routes.each do |banned_route|
              if banned_route['id'].blank?
                banned_routes_string +=  first_feed_id.to_s + '_' + banned_route['short_name'] + ','
              else
                banned_routes_string += banned_route['id'].split(':').first + '_' + banned_route['short_name'] + ','
              end
            end
            tp.banned_routes = banned_routes_string.chop
          end

          #Set Preferred Routes
          unless preferred_routes.blank?
            preferred_routes_string = ""
            preferred_routes.each do |preferred_route|
              if preferred_route['id'].blank?
                preferred_routes_string += first_feed_id.to_s + '_' + preferred_route['short_name'] + ','
              else
                preferred_routes_string += preferred_route['id'].split(':').first + '_' + preferred_route['short_name'] + ','
              end

            end
            tp.preferred_routes = preferred_routes_string.chop
          end

          #Save Trip Part
          raise 'TripPart not valid' unless tp.valid?
          trip.trip_parts << tp

          #Seems redundant
          if tp.sequence == 0
            trip.scheduled_date = tp.scheduled_date
            trip.scheduled_time = tp.scheduled_time
            puts "trip.save (2)"
            benchmark { trip.save }
          end


          puts 'Phase 1 ###########################################################################################################'
          puts Time.now - start_phase_1
          start_phase_2 = Time.now

          #Build the itineraries

          puts 'Creating Itineraries'

          start = Time.now
          otp_response = tp.create_itineraries
          puts 'Create Itineraries #######################################################################################################'
          puts Time.now - start

          my_itins = nil
          benchmark { my_itins = Itinerary.where(trip_part: tp).order('created_at') }
          #my_itins = tp.itineraries

          Rails.logger.info('Trip part ' + tp.id.to_s + ' generated ' + tp.itineraries.count.to_s + ' itineraries')
          Rails.logger.info(tp.itineraries.inspect)
          #Append data for API
          itins_loop_start = Time.now
          my_itins.each do |itinerary|
            i_hash = itinerary.as_json(except: 'legs')
            mode = itinerary.mode
            i_hash[:mode] = {name: TranslationEngine.translate_text(mode.name), code: mode.code}
            i_hash[:segment_index] = itinerary.trip_part.sequence
            i_hash[:start_location] = itinerary.trip_part.trip.origin.build_place_details_hash
            i_hash[:end_location] = itinerary.trip_part.trip.destination.build_place_details_hash
            i_hash[:prebooking_questions] = itinerary.prebooking_questions
            i_hash[:bookable] = itinerary.is_bookable?
            if itinerary.service
              i_hash[:service_name] = itinerary.service.name
            else
              i_hash[:service_name] = ""
            end

            if itinerary.discounts
              i_hash[:discounts] = JSON.parse(itinerary.discounts)
            end


            #Open up the legs returned by OTP and augment the information
            unless itinerary.legs.nil?
              puts 'Load itinerary legs'
              yaml_legs = nil
              benchmark { yaml_legs = YAML.load(itinerary.legs) }

              legs_stuff_start = Time.now
              yaml_legs.each do |leg|
                #1 Add Service Names to Legs if a service exists in the DB that matches the agencyId
                unless leg['agencyId'].nil?
                  service = Service.where(external_id: leg['agencyId']).first
                  unless service.nil?
                    leg['serviceName'] = service.name
                  else
                    leg['serviceName'] = leg['agencyName'] || leg['agencyId']
                  end
                end

                #2 Check to see if this route_type is classified as a special route_type
                begin
                  puts 'Reading DB Config gtfs_special_route_types'
                  specials = nil
                  benchmark { specials = Oneclick::Application.config.gtfs_special_route_types }
                rescue Exception=>e
                  specials = []
                end
                if leg['routeType'].nil?
                  leg['specialService'] = false
                else
                  leg['specialService'] = leg['routeType'].in? specials
                end

                #3 Check to see if real-time is available for node stops
                unless leg['intermediateStops'].blank?
                  trip_time = tp.get_trip_time leg['tripId'], otp_response
                  unless trip_time.blank?
                    stop_times = trip_time['stopTimes']
                    leg['intermediateStops'].each do |stop|
                      stop_time = stop_times.detect{|hash| hash['stopId'] == stop['stopId']}
                      stop['realtimeArrival'] = stop_time['realtimeArrival']
                      stop['realtimeDeparture'] = stop_time['realtimeDeparture']
                      stop['arrivalDelay'] = stop_time['arrivalDelay']
                      stop['departureDelay'] = stop_time['departureDelay']
                      stop['realtime'] = stop_time['realtime']

                    end
                  end
                end

                #4 If a location is a ParkNRide Denote it
                if leg['mode'] == 'CAR' and itinerary.returned_mode_code == Mode.park_transit.code
                  leg['to']['parkAndRide'] = true
                end

              end
              itinerary.legs = yaml_legs.to_yaml
              puts "itinerary.save"
              benchmark { itinerary.save }
              puts 'Legs Stuff #########################################################'
              puts Time.now - legs_stuff_start
              total_legs_stuff += (Time.now - legs_stuff_start)
            end

            if itinerary.legs
              start = Time.now
              i_hash[:json_legs] = (YAML.load(itinerary.legs)).as_json
              puts 'Load Legs #######################################################################################################'
              puts Time.now - start
            else
              i_hash[:json_legs] = nil
            end

            final_itineraries.append(i_hash)

          end

        end


        puts 'Itins Loop  #######################################################################################################'
        puts Time.now - itins_loop_start

        puts 'Phase 2 ###########################################################################################################'
        puts Time.now - start_phase_2
        start_phase_3 = Time.now

        Rails.logger.info('Sending ' + final_itineraries.count.to_s + ' in the response.')

        puts 'Checking to see if origin is in a CallNRide Zone'
        origin_in_callnride = nil
        origin_callnride = nil
        start = Time.now
        benchmark { origin_in_callnride, origin_callnride = trip.origin.within_callnride? }
        puts 'Checking to see if destination is in a CallNRide Zone'
        puts 'Checking to see if destination is in a CallNRide##################################################################'
        puts Time.now - start
        destination_in_callnride = nil
        destination_callnride = nil

        start = Time.now
        benchmark { destination_in_callnride, destination_callnride = trip.destination.within_callnride? }
        puts 'Checking to see if destination is in a CallNRide##################################################################'
        puts Time.now - start
        render json: {trip_id: trip.id, origin_in_callnride: origin_in_callnride, origin_callnride: origin_callnride, destination_in_callnride: destination_in_callnride, destination_callnride: destination_callnride, trip_token: trip.token, modes: trip.desired_modes_raw, itineraries: final_itineraries}

        start = Time.now
        trip.save
        from_trip_place.save
        to_trip_place.save
        puts 'FINAL SAVE BEFORE SENDING #######################################################################################################'
        puts Time.now - start
        puts 'Phase 3 ###########################################################################################################'
        puts Time.now - start_phase_3

      end

      def book

        puts 'Viewing Booking Params'
        puts params.ai


        booking_request = params[:booking_request]
        booked_itineraries = []

        booking_request.each do |itinerary_hash|
          itinerary = Itinerary.find(itinerary_hash[:itinerary_id].to_i)

          puts 'viewing itinerary'
          puts itinerary.ai

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
        trip_link = params[:trip_link].nil? ? nil : params[:trip_link]

        email_itineraries.each do |email_itinerary|
          email_addresses = email_itinerary[:email_addresses]

          ids = email_itinerary[:itineraries].collect { |x| x[:id] }
          itineraries = Itinerary.where(id: ids)

          # for subject, get first trip
          trip = itineraries.first.trip_part.trip

          if !email_itinerary[:subject].nil?
            subject = email_itinerary[:subject]
          elsif trip.scheduled_time > Time.now
            subject = "Your Upcoming Ride on " + trip.scheduled_time.strftime('%_m/%e/%Y').gsub(" ","")
          else
            subject = "Your Ride on " + trip.scheduled_time.strftime('%_m/%e/%Y').gsub(" ","")
          end

          UserMailer.user_itinerary_email(email_addresses, itineraries, subject, '', @traveler, trip_link=nil).deliver

        end

        render json: {result: 200}

      end

      def map_status
        itinerary_ids = [params[:id]]
        statuses = Itinerary.where(id: itinerary_ids).collect{|i| {id: i.id, has_map: true, url: "/api/v1/itineraries/#{i.id}/create_map"}}
        render json: {:itineraries => statuses}
      end

      # This is unneeded since we are no longer using phantomjs
      def request_create_maps
        render json: {result: 200}
      end

      def create_map
        itinerary = Itinerary.find(params[:id])
        send_data create_static_map(itinerary), {:type => 'image/png', :filename => "#{params[:id]}.png" }
      end

      def yes_or_no value
        value.to_bool ? 1 : 0
      end
      
      def benchmark 
        puts "  user     system      total        real"
        puts Benchmark.measure { yield }
      end

    end #Itineraries Controller
  end #V1
end #API
