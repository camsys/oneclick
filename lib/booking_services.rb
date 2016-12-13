class BookingServices

  ########
  ##  Booking services divies up all the booking functionality calls between 1-Click and the booking services
  ##  The calls include book, cancel, associate user, and other utility functions
  ##  This library routes the calls to the agency-specific libraries, specifically ecolane_services.rb, ridepilot_services.rb, and trapeze_services.rb
  ##  This library has knowledge of 1-click objects e.g., service.rb, user.rb, etc.  The individual agency-specific libraries do not have knowledge of these objects.
  ########

  require 'indirizzo'
  require 'street_address'
  include ActionView::Helpers::NumberHelper

  ##### Constants ####
  AGENCY = {
      :ecolane => 0,
      :trapeze => 1,
      :ridepilot => 2
  }

  # Called from itinerary.book
  # This is the generic itinerary booking method.  It calls the appropriate agency_services depending on which agency
  # is being used to book the trip E.g., RidePilot, Ecoloane, or Trapeze
  def book itinerary

    if itinerary.is_booked?
      return {trip_id: itinerary.trip_part.trip.id, itinerary_id: itinerary.id, booked: false, confirmation: nil, message: "This itinerary is already booked."}
    end

    case itinerary.service.booking_profile

      when AGENCY[:ecolane]

        service = itinerary.service
        user = itinerary.trip_part.trip.user
        user_service = UserService.find_by(user_profile: user.user_profile, service: service)
        es = EcolaneServices.new

        case service.ecolane_profile.api_version
          when "8"

            #Since ecolane_services.rb has no knowledge of Rails models, pull out the information needed here
            sponsors = service.sponsors.order(:index).pluck(:code).as_json
            trip_purpose_raw = itinerary.trip_part.trip.trip_purpose_raw
            is_depart = itinerary.trip_part.is_depart
            scheduled_time = itinerary.trip_part.scheduled_time
            from_trip_place = itinerary.trip_part.from_trip_place.as_json
            to_trip_place = itinerary.trip_part.to_trip_place.as_json
            note_to_driver = itinerary.ecolane_booking.note_to_driver
            assistant = itinerary.ecolane_booking.assistant
            companions = itinerary.ecolane_booking.companions
            children = itinerary.ecolane_booking.children
            other_passengers = itinerary.ecolane_booking.other_passengers
            customer_number = user_service.external_user_id
            system = service.ecolane_profile.system
            token = service.ecolane_profile.token

            #Get the default funding source for this customer and build an array of valid funding source ordered from
            # most desired to least desired.
            default_funding = get_default_funding_source(es.get_customer_id(customer_number, system, token), system, token)
            funding_array = [default_funding] +   FundingSource.where(service: service).order(:index).pluck(:code)

            result, messages = es.book_itinerary(sponsors, trip_purpose_raw, is_depart, scheduled_time, from_trip_place, to_trip_place, note_to_driver, assistant, companions, children, other_passengers, customer_number, funding_array, system, token)
            Rails.logger.info messages
            itinerary.booking_confirmation = messages
            itinerary.save

          when "9"
            puts 'Booking v9'
            ecolane_params = {
              trip_purpose_raw: itinerary.trip_part.trip.trip_purpose_raw,
              is_depart: itinerary.trip_part.is_depart,
              scheduled_time: itinerary.trip_part.scheduled_time,
              from_trip_place: itinerary.trip_part.from_trip_place.as_json,
              to_trip_place: itinerary.trip_part.to_trip_place.as_json,
              note_to_driver: itinerary.ecolane_booking.note_to_driver,
              assistant: itinerary.ecolane_booking.assistant,
              companions: itinerary.ecolane_booking.companions,
              children: itinerary.ecolane_booking.children,
              other_passengers: itinerary.ecolane_booking.other_passengers,
              customer_number: user_service.external_user_id,
              system: service.ecolane_profile.system,
              token: service.ecolane_profile.token,
              funding_source: itinerary.ecolane_booking.funding_source,
              sponsor: itinerary.ecolane_booking.sponsor
            }

            result, messages = es.book_itinerary_v9(ecolane_params)
            Rails.logger.info messages
            itinerary.booking_confirmation = messages
            itinerary.save
        end

      when AGENCY[:trapeze]
        user = itinerary.trip_part.trip.user
        user_service = UserService.find_by(user_profile: user.user_profile, service: itinerary.service)

        trapeze_profile = itinerary.service.trapeze_profile

        origin = itinerary.trip_part.from_trip_place
        parsed_address = get_parsed_address(origin.raw_address.blank? ? origin.address1 : origin.raw_address)
        origin_hash = {street_no: parsed_address.number, on_street: parsed_address.street.to_s + ' ' + parsed_address.street_type.to_s, unit: origin.unit, city: origin.city, state: origin.state, zip_code: origin.zip, lat: origin.lat, lon: origin.lon}

        destination = itinerary.trip_part.to_trip_place
        parsed_address = get_parsed_address(destination.raw_address.blank? ? destination.address1 : destination.raw_address)
        destination_hash = {street_no: parsed_address.number, on_street: parsed_address.street.to_s + ' ' + parsed_address.street_type.to_s, unit: destination.unit, city: destination.city, state: destination.state, zip_code: destination.zip, lat: destination.lat, lon: destination.lon}


        ts = TrapezeServices.new
        result = ts.pass_create_trip(trapeze_profile.endpoint, trapeze_profile.namespace, trapeze_profile.username, trapeze_profile.password, trapeze_profile.para_service_id, user_service.external_user_id,user_service.user_password, origin_hash, destination_hash, itinerary.start_time.seconds_since_midnight.to_i, itinerary.end_time.seconds_since_midnight.to_i, trapeze_profile.booking_offset_minutes, itinerary.start_time.strftime("%Y%m%d"), itinerary.trip_part.booking_trip_purpose_id, itinerary.trip_part.is_depart, itinerary.trapeze_booking.passenger1_type, itinerary.trapeze_booking.passenger2_type, itinerary.trapeze_booking.passenger3_type, itinerary.trapeze_booking.fare1_type_id, itinerary.trapeze_booking.fare2_type_id, itinerary.trapeze_booking.fare3_type_id, itinerary.trapeze_booking.passenger1_space_type, itinerary.trapeze_booking.passenger2_space_type, itinerary.trapeze_booking.passenger3_space_type)
        result = result.to_hash

        booking_id = result[:envelope][:body][:pass_create_trip_response][:pass_create_trip_result][:booking_id]
        message = result[:envelope][:body][:pass_create_trip_response][:pass_create_trip_result][:message]

        Rails.logger.info result.ai

        if booking_id.to_i == -1 #Failed to book

          begin
            message= TranslationEngine.translate_text(:booking_failure_message)
            items = result[:envelope][:body][:pass_create_trip_response][:validation][:item]
            unless items.kind_of?(Array) #Check to see if this is an array or a single item
              message = items[:message]
            else
              items.each do |item|
                if item[:type] == 'error'
                  message = item[:message]
                  break
                end
              end
            end
          rescue
            message= TranslationEngine.translate_text(:booking_failure_message)
          end
          return {trip_id: itinerary.trip_part.trip.id, itinerary_id: itinerary.id, booked: false, confirmation: nil, fare: nil, message: message}
        else
          itinerary.booking_confirmation = booking_id
          fare = result[:envelope][:body][:pass_create_trip_response][:pass_create_trip_result][:fare_amount]
          itinerary.cost = fare.blank? ? nil : fare.to_f

          ### Get and Unpack Times
          times_hash = ts.get_estimated_times(trapeze_profile.endpoint, trapeze_profile.namespace, trapeze_profile.username, trapeze_profile.password, user_service.external_user_id, user_service.user_password, booking_id)
          unless times_hash[:neg_time].nil?
            itinerary.negotiated_pu_time = Chronic.parse((itinerary.trip_part.scheduled_time.to_date.to_s) + " " +  seconds_since_midnight_to_string(times_hash[:neg_time]))
            itinerary.negotiated_pu_window_start = Chronic.parse((itinerary.trip_part.scheduled_time.to_date.to_s) + " " +  seconds_since_midnight_to_string(times_hash[:neg_early]))
            itinerary.negotiated_pu_window_end = Chronic.parse((itinerary.trip_part.scheduled_time.to_date.to_s) + " " +  seconds_since_midnight_to_string(times_hash[:neg_late]))
            itinerary.start_time = itinerary.negotiated_pu_time
          end

          itinerary.save


        end

      when AGENCY[:ridepilot]
        rs = RidepilotServices.new

        ridepilot_profile = itinerary.service.ridepilot_profile
        user = itinerary.trip_part.trip.user
        user_service = UserService.find_by(user_profile: user.user_profile, service: itinerary.service)

        origin = itinerary.trip_part.from_trip_place
        from_hash = origin.build_place_details_hash
        from = {address: from_hash, address_name: nil, note: nil, in_district: nil}

        destination = itinerary.trip_part.to_trip_place
        to_hash = destination.build_place_details_hash
        to = {address: to_hash, address_name: nil, note: nil, in_district: nil}

        ridepilot_booking = itinerary.ridepilot_booking
        result, body = rs.create_trip(ridepilot_profile.endpoint, ridepilot_profile.api_token, ridepilot_profile.provider_id, user_service.external_user_id, user_service.user_password, ridepilot_booking.trip_purpose_code, leg = itinerary.trip_part.sequence + 1, from, to, guests = ridepilot_booking.guests, attendants = ridepilot_booking.attendants, mobility_devices = ridepilot_booking.mobility_devices, itinerary.start_time.iso8601, itinerary.end_time.iso8601)
        if result
          itinerary.booking_confirmation = body["trip_id"]
          itinerary.negotiated_pu_time = itinerary.start_time
          ridepilot_booking.booking_status_code = body["status"]["code"]
          ridepilot_booking.booking_status_name = body["status"]["name"]
          ridepilot_booking.booking_status_message = body["status"]["message"]
          itinerary.save
          ridepilot_booking.save
          return {trip_id: itinerary.trip_part.trip.id, itinerary_id: itinerary.id, booked: true, negotiated_pu_time:  (itinerary.negotiated_pu_time.blank? ? "n/a" : itinerary.negotiated_pu_time.strftime("%b %e, %l:%M %p")), confirmation: body["trip_id"], fare: nil, message: body["status"]["code"], booking_status_message: ridepilot_booking.booking_status_message}
        else
          return {trip_id: itinerary.trip_part.trip.id, itinerary_id: itinerary.id, booked: false, negotiated_pu_time: nil, negotiated_pu_window_start: nil, negotiated_pu_window_end: nil, confirmation: nil, fare: nil, message: ""}
        end
      else
        return {trip_id: itinerary.trip_part.trip.id, itinerary_id: itinerary.id, booked: false, negotiated_pu_time: nil, negotiated_pu_window_start: nil, negotiated_pu_window_end: nil, confirmation: nil, fare: nil, message: ""}
    end

  end


  # Cancels a booked itinerary from the appropriate agency.
  def cancel itinerary
    # return true is successful, false if not successful

    user = itinerary.trip_part.trip.user
    user_service = UserService.find_by(user_profile: user.user_profile, service: itinerary.service)

    case itinerary.service.booking_profile

      when AGENCY[:ecolane]
        ecolane_profile = itinerary.service.ecolane_profile
        es = EcolaneServices.new
        ecolane_params = {confirmation_number: itinerary.booking_confirmation, system: ecolane_profile.system, token: ecolane_profile.token}
        result = es.cancel(ecolane_params)

      when AGENCY[:trapeze]
        trapeze_profile = itinerary.service.trapeze_profile
        ts = TrapezeServices.new
        return ts.cancel_trip(trapeze_profile.endpoint, trapeze_profile.namespace, trapeze_profile.username, trapeze_profile.password, user_service.external_user_id, user_service.user_password, itinerary.booking_confirmation)

      when AGENCY[:ridepilot]
        ridepilot_profile = itinerary.service.ridepilot_profile
        rs = RidepilotServices.new
        result, body = rs.cancel_trip(ridepilot_profile.endpoint, ridepilot_profilqe.api_token, user_service.external_user_id, user_service.user_password, itinerary.booking_confirmation)
        return result

    end
  end

  #Cancels a booked trips that was not made from 1-Click
  def cancel_external booking_confirmation, user

    unless trip_belongs_to_user? booking_confirmation, user
      return false
    end

    #This currently only works for Ecolane.  Ecolane users only have one service profile
    user_service =  user.user_profile.user_services.first
    service = user_service.service

    case service.booking_profile
      when AGENCY[:ecolane]
        ecolane_profile = service.ecolane_profile
        es = EcolaneServices.new
        ecolane_params = {booking_confirmation: booking_confirmation, system: ecolane_profile.system, token: ecolane_profile.token}
        result = es.cancel(ecolane_params)
        return result
    end
  end

  def trip_belongs_to_user? booking_confirmation, user
    #This currently only works for Ecolane.  Ecolane users only have one service profile
    user_service =  user.user_profile.user_services.first
    service = user_service.service
    ecolane_profile = service.ecolane_profile
    es = EcolaneServices.new

    request_params =
        {booking_confirmation: booking_confirmation,
        system: ecolane_profile.system,
        token: ecolane_profile.token,
        customer_number: user_service.external_user_id}
    es.trip_belongs_to_user?(request_params)
  end

  # Given a service, a user, and login credentials, test to see if the login credentials are valid, if they are create
  # a user_service to link the service and the user.  This user_service contains all the information necessary to allow the user to book trips with the given service
  # This method returns a boolean
  def associate_user(service, user, external_user_id, external_user_password)

    case service.booking_profile
      when AGENCY[:ecolane]
        ecolane_profile = service.ecolane_profile

        es = EcolaneServices.new
        result, first_name, last_name, home = es.validate_passenger(external_user_id, external_user_password, ecolane_profile.system, ecolane_profile.token)
        if result
          #For Ecolane, we create a new user if the user doesn't exist
          user_service = get_or_create_ecolane_traveler(external_user_id, external_user_password, service, first_name, last_name)
        end
        return result, user_service

      when AGENCY[:trapeze]
        trapeze_profile = service.trapeze_profile
        ts = TrapezeServices.new
        result = ts.pass_validate_client_password(trapeze_profile.endpoint, trapeze_profile.namespace, trapeze_profile.username, trapeze_profile.password, external_user_id, external_user_password)
        us = nil
        if result
          us = UserService.where(service: service, user_profile: user.user_profile).first_or_initialize
          us.external_user_id = external_user_id
          us.user_password = external_user_password
          us.save
        end
        return result, us
      when AGENCY[:ridepilot]
        ridepilot_profile = service.ridepilot_profile
        rs = RidepilotServices.new
        result, body = rs.authenticate_customer(ridepilot_profile.endpoint, ridepilot_profile.api_token, ridepilot_profile.provider_id, external_user_id, external_user_password)
        us = nil
        if result
          us = UserService.where(service: service, user_profile: user.user_profile).first_or_initialize
          us.external_user_id = external_user_id
          us.user_password = external_user_password
          us.save
        end
        return result, us
    end
  end

  # Given a service and a user, test to see if the user's login credentials are present and still valid to book with the given service
  # This method returns a boolean
  def check_association(service, user)
    user_service = UserService.find_by(service: service, user_profile: user.user_profile)
    if user_service.nil?
      return false
    end

    case service.booking_profile
      when AGENCY[:ecolane]
        ecolane_profile = service.ecolane_profile
        es = EcolaneServices.new
        result, first_name, last_name = es.validate_passenger(external_user_id, external_user_password, ecolane_profile.system, ecolane_profile.token)
        return result
      when AGENCY[:trapeze]
        trapeze_profile = service.trapeze_profile
        ts = TrapezeServices.new
        return ts.pass_validate_client_password(trapeze_profile.endpoint, trapeze_profile.namespace, trapeze_profile.username, trapeze_profile.password, user_service.external_user_id, user_service.user_password)
      when AGENCY[:ridepilot]
        ridepilot_profile = service.ridepilot_profile
        rs = RidepilotServices.new
        result, body = rs.authenticate_customer(ridepilot_profile.endpoint, ridepilot_profile.api_token, ridepilot_profile.provider_id, user_service.external_user_id, user_service.user_password)
        return result
    end
  end

  #Utility function needed to parse the address number and street name from a raw address
  def get_parsed_address(raw_address)
    return StreetAddress::US.parse(raw_address)
  end

  #Utility function needed to convert seconds since midnight into a parsable time string
  def seconds_since_midnight_to_string(seconds_since_midnight)
    seconds_since_midnight = seconds_since_midnight.to_i
    hour =seconds_since_midnight/3600
    minute = (seconds_since_midnight - (hour*3600))/60
    second = seconds_since_midnight - (hour*3600) - (minute*60)
    hour = (hour < 10) ? "0" + hour.to_s : hour.to_s
    return hour + ':' + minute.to_s + ":" + second.to_s
  end


  def get_purposes_from_itinerary(itinerary)
    service = itinerary.service
    user = itinerary.trip_part.trip.user
    user_service = UserService.find_by(service: service, user_profile: user.user_profile)

    if user_service.nil?
      return {}
    else
      return get_purposes(user_service)
    end

  end


  # Get purposes returns a list of valid purpuoses for the user to select from when booking.
  # The format of the purposes is {purpose_description_1: purpose_code_1, purpose_description_2: purpose_code_2, etc. }
  def get_purposes(user_service)

    if user_service.nil?
      return {}
    end

    service = user_service.service

    case service.booking_profile
      when AGENCY[:ecolane]

       ecolane_profile = service.ecolane_profile
        es = EcolaneServices.new
        purposes = es.get_trip_purposes(es.get_customer_id( user_service.external_user_id,
                                                            ecolane_profile.system,
                                                            ecolane_profile.token
                                                            ),
                                        ecolane_profile.system,
                                        ecolane_profile.token,
                                        ecolane_profile.disallowed_purposes
                                        )

        #This creates a hash for the purposes.  For Ecolane the description/name and id are the same.
        purposes_hash = {}
        purposes.each do |purpose|
          purposes_hash[purpose] = purpose
        end

        return purposes_hash

      when AGENCY[:trapeze]
        trapeze_profile = service.trapeze_profile
        ts = TrapezeServices.new
        purposes = ts.get_booking_purposes(trapeze_profile.endpoint, trapeze_profile.namespace, trapeze_profile.username, trapeze_profile.password, user_service.external_user_id, user_service.user_password)
        purpose_hash= {}
        purposes.each do |purpose|
          purpose_hash[purpose[:description]] = purpose[:booking_purpose_id]
        end

        return purpose_hash.sort.to_h

      when AGENCY[:ridepilot]
        ridepilot_profile = service.ridepilot_profile
        rs = RidepilotServices.new
        result, body = rs.trip_purposes(ridepilot_profile.endpoint, ridepilot_profile.api_token, ridepilot_profile.provider_id)
        purposes_hash = {}
        if result
          body["trip_purposes"].each do |purpose|
            purposes_hash[purpose["name"]] = purpose["code"]
          end
        end

        return purposes_hash.sort.to_h

    end
  end

  def get_passenger_types_from_itinerary(itinerary)

    user_service = UserService.find_by(service: itinerary.service, user_profile: itinerary.trip_part.trip.user.user_profile)
    return get_passenger_types(user_service)

  end

  def get_passenger_types(user_service)

    if user_service.nil?
      return {}
    end

    service = user_service.service

    case service.booking_profile
      when AGENCY[:ecolane]
        return {}
      when AGENCY[:trapeze]
        trapeze_profile = service.trapeze_profile
        ts = TrapezeServices.new
        passenger_types = ts.get_passenger_types(trapeze_profile.endpoint, trapeze_profile.namespace, trapeze_profile.username, trapeze_profile.password, user_service.external_user_id, user_service.user_password)
        passenger_types_hash = {}
        passenger_types.each do |passenger_type|
          passenger_types_hash[passenger_type[:description]] = passenger_type[:abbreviation] + "%%" + passenger_type[:fare_type_id]
        end
        return passenger_types_hash
    end

  end

  def get_space_types_from_itinerary(itinerary)
    service = itinerary.service
    user = itinerary.trip_part.trip.user
    user_service = UserService.find_by(service: service, user_profile: user.user_profile)

    return get_space_types(user_service)

  end

  def authenticate_provider_from_profile(booking_profile)
    service = booking_profile.service
    authenticate_provider(booking_profile.endpoint, booking_profile.api_token, booking_profile.provider_id, service.booking_profile)
  end

  def authenticate_provider(endpoint, api_token, provider_id, booking_profile)

    case booking_profile.to_i
      when AGENCY[:ridepilot]
        rp = RidepilotServices.new
        result, body = rp.authenticate_provider(endpoint, api_token, provider_id)
        return {authenticated: result, message: body["error"]}
    end
  end

  def get_space_types(user_service)

    if user_service.nil?
      return {}
    end

    service = user_service.service

    case service.booking_profile
      when AGENCY[:ecolane]
        return {}
      when AGENCY[:trapeze]
        trapeze_profile = service.trapeze_profile
        ts = TrapezeServices.new
        space_types = ts.get_space_types(trapeze_profile.endpoint, trapeze_profile.namespace, trapeze_profile.username, trapeze_profile.password, user_service.external_user_id, user_service.user_password)
        space_types_hash = {}
        space_types.each do |space_type|
          space_types_hash[space_type[:description]] = space_type[:abbreviation]
        end
        return space_types_hash
    end
  end

  def update_trip_status(itinerary)   #TODO; Returned objects should be consistent across agencies
    service = itinerary.service
    user = itinerary.trip_part.trip.user
    user_service = UserService.find_by(service: service, user_profile: user.user_profile)

    case service.booking_profile
      when AGENCY[:ecolane]
        es = EcolaneServices.new
        status = es.get_trip_info(itinerary.booking_confirmation, service.ecolane_profile.system, service.ecolane_profile.token)

        unless status[0]
          return status
        end

        itinerary.negotiated_pu_time = status[1][:pu_time]
        itinerary.negotiated_do_time = status[1][:do_time]
        itinerary.save

        return status
      when AGENCY[:ridepilot]
        ridepilot_profile = service.ridepilot_profile
        ridepilot_booking = itinerary.ridepilot_booking
        rs = RidepilotServices.new
        result, body = rs.trip_status(ridepilot_profile.endpoint, ridepilot_profile.api_token, user_service.external_user_id, user_service.user_password, itinerary.booking_confirmation)
        if result
          itinerary.booking_confirmation = body["trip_id"]
          itinerary.negotiated_pu_time = itinerary.start_time
          ridepilot_booking.booking_status_code = body["status"]["code"]
          ridepilot_booking.booking_status_name = body["status"]["name"]
          ridepilot_booking.booking_status_message = body["status"]["message"]
          itinerary.save
          ridepilot_booking.save
          return {trip_id: itinerary.trip_part.trip.id, itinerary_id: itinerary.id, booked: true, negotiated_pu_time:  (itinerary.negotiated_pu_time.blank? ? "n/a" : itinerary.negotiated_pu_time.strftime("%b %e, %l:%M %p")), confirmation: body["trip_id"], fare: nil, message: body["status"]["code"], booking_status_message: ridepilot_booking.booking_status_message}
        else
          return {trip_id: itinerary.trip_part.trip.id, itinerary_id: itinerary.id, booked: false, negotiated_pu_time: nil, negotiated_pu_window_start: nil, negotiated_pu_window_end: nil, confirmation: nil, fare: nil, message: ""}
        end
    end
  end

  def query_fare(itinerary)
    user = itinerary.trip_part.trip.user
    service = itinerary.service

    case service.booking_profile
      when AGENCY[:ecolane]
        es = EcolaneServices.new

        ##The next block makes the assumption that each user only belongs to 1 Booking Service.  This is the case for PA, but may not be the case for future deployments
        user = itinerary.trip_part.trip.user
        user_service = user.user_profile.user_services.first
        service = user_service.service
        ## End Assumption

        trip_purpose_raw = itinerary.trip_part.trip.trip_purpose_raw
        is_depart = itinerary.trip_part.is_depart
        scheduled_time = itinerary.trip_part.scheduled_time
        from_trip_place = itinerary.trip_part.from_trip_place.as_json
        to_trip_place = itinerary.trip_part.to_trip_place.as_json
        customer_number = user_service.external_user_id
        system = service.ecolane_profile.system
        token = service.ecolane_profile.token

        case service.ecolane_profile.api_version
          when "8"
            #Since ecolane_services.rb has no knowledge of Rails models, pull out the information needed here
            sponsors = service.sponsors.order(:index).pluck(:code).as_json

            #Get the default funding source for this customer and build an array of valid funding source ordered from
            # most desired to least desired.
            default_funding = get_default_funding_source(es.get_customer_id(customer_number, system, token), system, token)
            funding_array = [default_funding] +   FundingSource.where(service: service).order(:index).pluck(:code)

            ecolane_params  =
              {
                sponsors: sponsors,
                trip_purpose_raw: trip_purpose_raw,
                is_depart: is_depart,
                scheduled_time: scheduled_time,
                from_trip_place: from_trip_place,
                to_trip_place: to_trip_place,
                customer_number: customer_number,
                system: system,
                token: token,
                funding_array: funding_array
              }

            result, fare = es.query_fare(ecolane_params)
            if result
              return fare
            else
              return nil
            end
          when "9"
            ecolane_params  =
                {
                trip_purpose_raw: trip_purpose_raw,
                is_depart: is_depart,
                scheduled_time: scheduled_time,
                from_trip_place: from_trip_place,
                to_trip_place: to_trip_place,
                customer_number: customer_number,
                system: system,
                token: token
            }
            result, resp_hash = es.query_preferred_fare(ecolane_params)
            if result
              ecolane_booking = EcolaneBooking.where(itinerary: itinerary).first_or_create
              ecolane_booking.funding_source = resp_hash[:funding_source]
              ecolane_booking.sponsor = resp_hash[:sponsor]
              ecolane_booking.save
              itinerary.ecolane_booking = ecolane_booking
              itinerary.save
              return resp_hash[:fare].to_f
            else
              return nil
            end
        end
      else
        return nil
    end
  end

  #Get All Future Trips and Convert them to a Hash to be returned by the API
  # TODO Update to do this for RidePilot and Trapeze
  def future_trips user, agency=AGENCY[:ecolane]

    case agency
      when AGENCY[:ecolane]
        es = EcolaneServices.new
        #Ecolane users only have one user_service
        user_service = user.user_profile.user_services.first
        if user_service.nil?
          return []
        end

        service = user_service.service

        #Get the info needed for the Ecolane API Call
        customer_number = user_service.external_user_id
        system = service.ecolane_profile.system
        token = service.ecolane_profile.token

        es = EcolaneServices.new

        future_trips = es.get_future_orders customer_number, system, token

        future_trips_not_cancelled = future_trips.select {|trip| trip['status'] != 'canceled'}

        build_api_trips_hash_array_from_ecolane_hash future_trips_not_cancelled

      else
        return []
    end
  end


  #Get All Future Trips and Convert them to a Hash to be returned by the API
  # TODO Update to do this for RidePilot and Trapeze
  def past_trips user, max_results = 10, end_time = Time.now.iso8601, agency=AGENCY[:ecolane]

    case agency
      when AGENCY[:ecolane]
        es = EcolaneServices.new
        #Ecolane users only have one user_service
        user_service = user.user_profile.user_services.first
        if user_service.nil?
          return []
        end

        service = user_service.service

        #Get the info needed for the Ecolane API Call
        customer_number = user_service.external_user_id
        system = service.ecolane_profile.system
        token = service.ecolane_profile.token

        es = EcolaneServices.new

        #Why is max_results doubled?  Because, ecolane sends back round trips as two trips.
        past_trips = es.get_past_orders(customer_number, max_results*2, end_time, system, token)
        build_api_trips_hash_array_from_ecolane_hash past_trips

      else
        return []
    end
  end

  def get_trip_details user_service, booking_confirmation

    service = user_service.service

    case service.booking_profile
    when AGENCY[:ecolane]
      es = EcolaneServices.new
      response = es.fetch_single_order(booking_confirmation, service.ecolane_profile.system, service.ecolane_profile.token)
      Hash.from_xml(response.body)
    end
  end

  ####################################
  # Ecolane Specific Functions
  # Find the default funding source for a customer id.  Used by Ecolane
  # (customer_id is the internal id and not the client id)
  ###################################
  def get_default_funding_source(customer_id, system_id, token)
    es = EcolaneServices.new
    customer_information = es.fetch_customer_information(customer_id, system_id, token, funding = true)
    resp_xml = Nokogiri::XML(customer_information)
    resp_xml.xpath("customer").xpath("funding").xpath("funding_source").each do |funding_source|
      if funding_source.attribute("default") and funding_source.attribute("default").value.downcase == "yes"
        return funding_source.xpath("name").text
      end
    end
    nil
  end

  # Updates the status of booked trips by making a call to external booking services
  def update_booked_trip_statuses user_service
    # Is there an ecolane profile associated with this service?
    return false if user_service.service.ecolane_profile.nil?

    customer_id = user_service.external_user_id
    booking_system = user_service.service.ecolane_profile.system
    token = user_service.service.ecolane_profile.token
    es = EcolaneServices.new
    resp = es.fetch_customer_orders(customer_id, booking_system, token)
    orders = es.unpack_orders(resp)
    return false unless orders[0] # Return false if ecolane call returns an error.
    response_array = []
    orders.each do |order|
      # Find itinerary based on ecolane booking confirmation id
      itin = Itinerary.joins(:ecolane_booking).find_by(ecolane_bookings: {confirmation_number: order["id"]})
      unless itin.nil?
        eb = EcolaneBooking.where(itinerary: itin).first_or_create
        response_array << eb.id if itin.ecolane_booking.update_attributes(booking_status_code: order["status"])
      end
    end
    return response_array # Return an array of successfully updated Ecolane Booking ids
  end

  # Finds the first service it can set to book trips in the given county
  def county_to_service(county)
    ep = EcolaneProfile.where("booking_counties like ?", "% #{county.humanize}\n%").first
    if ep
      return ep.service
    else
      return nil
    end
  end

  # DEPRECATED?
  def county_to_external_id county
    Service.paratransit.active.each do |service|
      counties = service.county_endpoint_array || []
      counties.map!(&:downcase)
      if county.downcase.in? counties
        return service.external_id
      end
    end
    return county
  end

  def get_or_create_ecolane_traveler(external_user_id, dob, service, first_name, last_name)
    user_service = UserService.where(external_user_id: external_user_id, service: service).order('created_at').last
    booking_system = service.ecolane_profile.nil? ? nil : service.ecolane_profile.system.to_s
    if user_service
      u = user_service.user_profile.user
    else
      new_user = true
      u = User.where(email: external_user_id.gsub(" ","_") + '_' + booking_system + '@ecolane_user.com').first_or_create
      u.first_name = first_name
      u.last_name = last_name
      u.password = dob
      u.password_confirmation = dob
      u.roles << Role.where(name: "registered_traveler").first
      result = u.save!
    end

    user_profile = u.user_profile

    #Update Birth Year
    dob_object = Characteristic.where(code: "date_of_birth").first
    if dob_object
      user_characteristic = UserCharacteristic.where(characteristic_id: dob_object.id, user_profile_id: user_profile.id).first_or_initialize
      user_characteristic.value = dob.split('/')[2]
      user_characteristic.save
    end

    if new_user #Create User Service
      user_service = UserService.where(user_profile_id: user_profile.id, service_id: service.id).first_or_initialize
      user_service.external_user_id = external_user_id
      user_service.save
    end

    #Create Home from Ecolane If it Exists
    current_home = u.home
    ecolane_profile = service.ecolane_profile
    es = EcolaneServices.new
    home = es.get_passenger_home(external_user_id, ecolane_profile.system, ecolane_profile.token)
    if home
      my_place = Place.new
      my_place.city = home['city']
      my_place.county = home['county']
      my_place.lat = home['latitude']
      my_place.lon = home['longitude']
      my_place.name = "Home"
      my_place.zip = home['postcode']
      my_place.state = home['state']
      my_place.address1 = home['street_number'].to_s + ' ' + home['street'].to_s
      my_place.user = user_profile.user
      my_place.home = true
      my_place.save
      if current_home
        current_home.delete
      end
    end

    return user_service

  end

  def get_dummy_trip_purposes(service)
    customer_number = service.fare_user #String of the Dummy customer_number
    ecolane_profile = service.ecolane_profile
    disallowed_purposes_array = ecolane_profile.disallowed_purposes
    es = EcolaneServices.new
    es.get_trip_purposes(es.get_customer_id(customer_number, ecolane_profile.system, ecolane_profile.token), ecolane_profile.system, ecolane_profile.token, disallowed_purposes_array)
  end

  def get_top_purposes(purposes)

    #Get a list of top purposes:  TODO expand this to include the passengers recent trips. Those are more likely than a global setting of top trip purposes.
    top_purposes = Oneclick::Application.config.top_ecolane_purposes

    top_purposes = (top_purposes & purposes)[0 .. 3] #Find the intersection of top purposes and purposes for this person.  Take the top 4

    #If there aren't at least 4, then add in more until we reach four.
    if top_purposes.count < 4
      additional_top = (purposes - top_purposes)[0 .. (4 - top_purposes.count - 1)]
      top_purposes = top_purposes + additional_top
    end

    #This creates a hash for the purposes.  For Ecolane the description/name and id are the same.
    purposes_hash = {}
    purposes.each do |purpose|
      purposes_hash[purpose] = purpose
    end

    #This creates a hash for the TOP purposes.  For Ecolane the description/name and id are the same.
    top_purposes_hash = {}
    top_purposes.each do |purpose|
      top_purposes_hash[purpose] = purpose
    end

    return top_purposes_hash

  end

  def build_discount_array(itinerary)

    es = EcolaneServices.new
    service = itinerary.service

    case service.ecolane_profile.api_version
      when "8"
        #Since ecolane_services.rb has no knowledge of Rails models, pull out the information needed here
        system = service.ecolane_profile.system
        token = service.ecolane_profile.token
        funding_sources = service.funding_sources.as_json
        sponsors = service.sponsors.order(:index).pluck(:code).as_json
        trip_purpose = itinerary.trip_part.trip.trip_purpose_raw || service.ecolane_profile.default_trip_purpose
        customer_number = service.fare_user
        customer_id = es.get_customer_id(customer_number, system, token)
        assistant = itinerary.assistant
        companions = itinerary.companions
        children = itinerary.children
        other_passengers = itinerary.other_passengers
        is_depart = itinerary.trip_part.is_depart
        scheduled_time = itinerary.trip_part.scheduled_time
        to_trip_place = itinerary.trip_part.to_trip_place.as_json
        from_trip_place = itinerary.trip_part.from_trip_place.as_json
        return es.build_discount_array(funding_sources, sponsors, trip_purpose, customer_number, customer_id, assistant, companions, children, other_passengers, is_depart, scheduled_time, to_trip_place, from_trip_place, system, token)

      when "9"
        ecolane_params  =
        {
          is_depart: itinerary.trip_part.is_depart,
          scheduled_time: itinerary.trip_part.scheduled_time,
          to_trip_place: itinerary.trip_part.to_trip_place.as_json,
          from_trip_place: itinerary.trip_part.from_trip_place.as_json,
          system: service.ecolane_profile.system,
          token: service.ecolane_profile.token
        }
        return es.build_discount_array_v9(ecolane_params)

    end
  end

  #Take the hash of itineraries returned from Ecolane's future/past trips call and convert them to the
  # Itinerary Hash format that the API needs to return
  def build_api_trips_hash_array_from_ecolane_hash hashes

    trip_hashes = []

    #TODO: All trips are 1 itinerary.
    hashes.each do |hash|

      trip_hash = {}
      new_itinerary = {}
      new_itinerary[:mode] = 'mode_paratransit'
      new_itinerary[:booking_confirmation] = hash['id']
      new_itinerary[:system] = hash['system']
      new_itinerary[:customer_id] = hash['customer_id']
      new_itinerary[:status] = hash['status']
      new_itinerary[:departure] = hash['pickup']['negotiated']
      new_itinerary[:arrival] = hash['dropoff']['negotiated']
      new_itinerary[:cost] = (hash['fare']['client_copay'].to_f)/100.0
      new_itinerary[:fare] = (hash['fare']['client_copay'].to_f)/100.0
      new_itinerary[:assistant] = hash['assistant']
      new_itinerary[:children] = hash['children']
      new_itinerary[:companions] = hash['companions']
      new_itinerary[:origin] = google_place_from_ecolane_location(hash['pickup']['location'])
      new_itinerary[:destination] = google_place_from_ecolane_location(hash['dropoff']['location'])
      new_itinerary[:walk_time] = 0
      new_itinerary[:walk_distance] = 0
      new_itinerary[:transfers] = 0
      new_itinerary[:json_legs]= nil

      if hash['pickup'].nil? || hash['pickup']['negotiated'].nil?
        wait_start = nil
        wait_end = nil
      else
        wait_start = (hash['pickup']['negotiated'].to_time - 15*60).iso8601[0...-6]
        wait_end = (hash['pickup']['negotiated'].to_time + 15*60).iso8601[0...-6]
      end

      new_itinerary[:wait_start] =  wait_start
      new_itinerary[:wait_end] = wait_end

      if hash['pickup']['negotiated'] and hash['dropoff']['negotiated']
        new_itinerary[:duration] = Time.parse(hash['dropoff']['negotiated']) - Time.parse(hash['pickup']['negotiated'])
        new_itinerary[:transit_time] = new_itinerary[:duration]
      end

      trip_hash[0] = new_itinerary
      trip_hashes << trip_hash

    end

    trip_hashes

  end

  def build_api_trip_hash_from_non_paratransit_trip trip

    itineraries = trip.selected_itineraries
    trip_hash = {}

    itineraries.each do |itinerary|
      itinerary_hash = {}
      itinerary_hash[:trip_id] = itinerary.trip_part.trip.id
      itinerary_hash[:id] = itinerary.id
      itinerary_hash[:mode] = itinerary.returned_mode_code || itinerary.mode.code
      itinerary_hash[:departure] = itinerary.start_time.iso8601
      itinerary_hash[:arrival] = itinerary.end_time.iso8601
      itinerary_hash[:fare] = itinerary.cost.to_f
      itinerary_hash[:cost] = itinerary.cost.to_f
      itinerary_hash[:origin] = itinerary.origin.build_place_details_hash
      itinerary_hash[:destination] = itinerary.destination.build_place_details_hash
      itinerary_hash[:duration] = itinerary.duration
      itinerary_hash[:walk_time] =  itinerary.walk_time
      itinerary_hash[:transit_time] = itinerary.transit_time
      itinerary_hash[:wait_time] = itinerary.wait_time
      itinerary_hash[:walk_distance] = itinerary.walk_distance
      itinerary_hash[:transfers] = itinerary.transfers
      itinerary_hash[:product_id] = itinerary.product_id

      if itinerary.service
        itinerary_hash[:service_name] = itinerary.service.name
        itinerary_hash[:phone] = itinerary.service.phone
        itinerary_hash[:logo_url]= itinerary.service.logo_url
        comment = itinerary.service.comments.where(locale: "en").first
        if comment
          itinerary_hash[:comment] = comment.comment
        end
      else
        itinerary_hash[:service_name] = ""
      end



      unless itinerary.legs.blank?
        itinerary_hash[:json_legs] = (YAML.load(itinerary.legs || "")).as_json
      end
      itinerary_hash[:status] = itinerary.selected ? "active" : "canceled"
      trip_hash[itinerary.trip_part.sequence] =  itinerary_hash
    end

    return trip_hash

  end

  def google_place_from_ecolane_location location

    #Based on Google Place Details
    {
      address_components: address_components(location),

      formatted_address: location['street_number'].to_s + ' ' + location['street'].to_s + ', ' + location['city'].to_s + ', ' + location['state'].to_s,
      geometry: {
        location: {
          lat: location['latitude'],
          lng: location['longitude'],
        }
      }
    }

  end

  def address_components location
    address_components = []

    #street_number
    if location['street_number']
      address_components << {long_name: location['street_number'], short_name: location['street_number'], types: ['street_number']}
    end

    #Route
    if location['street']
      address_components << {long_name: location['street'], short_name: location['street'], types: ['route']}
    end

    #Street Address
    if location['street_number'] and location['street']
      address_components << {long_name: location['street_number'] + ' ' + location['street'], short_name: location['street_number'] + ' ' + location['street'], types: ['street_address']}
    end

    #City
    if location['city']
      address_components << {long_name: location['city'], short_name: location['city'], types: ["locality", "political"]}
    end

    #State
    if location['state']
      address_components << {long_name: location['state'], short_name: location['state'], types: ["postal_code"]}
    end

    return address_components

  end

  #Ecolane does not have a concept of roundtrips, 1-way trips should be grouped
  def group_trips trips_array

    new_array = []

    if trips_array.count == 0
      return []
    end

    if trips_array.count == 1
      return trips_array
    end

    skip = false
    trips_array.each_cons(2) do |trip, next_trip|

      #If this is already a round trip, keep moving.  It's already been added
      if skip
        skip = false
        next
      end

      if trip.count > 1 or next_trip.count > 1
        new_array << trip
        next
      end

      #Are these trips on the same day?
      unless trip[0][:departure].to_date === next_trip[0][:departure].to_date
        new_array << trip
        next
      end

      #Does these trips have inverted origins/destinations?
      unless trip[0][:destination][:formatted_address] == next_trip[0][:origin][:formatted_address] and trip[0][:origin][:formatted_address] == next_trip[0][:destination][:formatted_address]
        new_array << trip
        next
      end

      #Ok these trips passed all the tests, combine them into one trip
      skip = true #This says to skip the next trip, because it's already been handled here
      new_trip = {0 => trip[0], 1 => next_trip[0]}
      new_array << new_trip

    end

    # We need to handle the last trip
    unless skip
      new_array << trips_array.last
    end

    return new_array
  end

  ####################################
  # End Ecolane Specific Functions
  ###################################

end
