class TrapezeServices

  require 'indirizzo'

  ########## BEGIN Setup client and authorize ###############
  def create_client(endpoint, namespace, username, password)

    client = Savon.client do
      endpoint endpoint
      namespace namespace
      basic_auth [username, password]
      convert_request_keys_to :camelcase
    end

    return client

  end

  def pass_validate_client_password(endpoint, namespace, username, password, client_id, client_password)

    begin
      client = create_client(endpoint, namespace, username, password)
      response = client.call(:pass_validate_client_password, message: {client_id: client_id, password: client_password})
    rescue
      return false
    end

    if response.to_hash[:pass_validate_client_password_response][:validation][:item][:code] == "RESULTOK"
      return true
    else
      return false
    end
  end

  def login(client_id, password, client)
    result = client.call(:pass_validate_client_password, message: {client_id: client_id, password: password})
    auth_cookies = result.http.cookies
    return auth_cookies
  end

  def create_client_and_login(endpoint, namespace, username, password, client_id, client_password)
    client = create_client(endpoint, namespace, username, password)
    auth_cookies = login(client_id, client_password, client)
    return client, auth_cookies
  end

  ########## END Setup client and authorize ###############

  def pass_get_client_info(endpoint, namespace, username, password, client_id, client_password)
    client, auth_cookies = create_client_and_login(endpoint, namespace, username, password, client_id, client_password)
    result = client.call(:pass_get_client_info, message: {client_id: client_id}, cookies: auth_cookies)
    result.hash
  end

  def pass_get_client_trips(endpoint, namespace, username, password, client_id, client_password)
    client, auth_cookies = create_client_and_login(endpoint, namespace, username, password, client_id, client_password)
    result = client.call(:pass_get_client_trips, message: {client_id: client_id}, cookies: auth_cookies)
    result.hash
  end

  def pass_get_schedules (endpoint, namespace, username, password, client_id, client_password)
    client, auth_cookies = create_client_and_login(endpoint, namespace, username, password, client_id, client_password)
    result = client.call(:pass_get_schedules, cookies: auth_cookies)
    result.hash
  end

  def pass_get_booking_purposes(endpoint, namespace, username, password, client_id, client_password)
    client, auth_cookies = create_client_and_login(endpoint, namespace, username, password, client_id, client_password)
    result = client.call(:pass_get_booking_purposes, cookies: auth_cookies)
    result.hash
  end

  def get_booking_purposes(endpoint, namespace, username, password, client_id, client_password)
    #Return an array of booking purposes
    result = pass_get_booking_purposes(endpoint, namespace, username, password, client_id, client_password)

    begin
      purpose_hash = result[:envelope][:body][:pass_get_booking_purposes_response][:pass_get_booking_purposes_result][:pass_booking_purpose]
      return purpose_hash
    rescue
      return {}
    end

  end

  def pass_create_trip_test(endpoint, namespace, username, password, client_id, client_password)

    #hardcoded for now
    pu_address_hash = {address_mode: 'ZZ', street_no: 100, on_street: "Myrtle Ave N", city: "Jacksonville", state: "FL", zip_code: "32204", lat: (30.330305*1000000).to_i, lon: (-81.677073*1000000).to_i, geo_status:  -2147483648 }
    pu_leg_hash = {req_time: 36300, request_address: pu_address_hash}

    do_address_hash = {address_mode: 'ZZ', street_no: 22, on_street: "E 3rd St", city: "Jacksonville", state: "FL", zip_code: "32206", lat: (30.339023*1000000).to_i, lon: (-81.653951*1000000).to_i, geo_status:  -2147483648}
    do_leg_hash = {request_address: do_address_hash}

    trip_hash = {client_id: 104584, client_code: '104584', date: '20150920', booking_type: 'C', auto_schedule: true, calculate_pick_up_req_time: true, booking_purpose_id: 2, pick_up_leg: pu_leg_hash, drop_off_leg: do_leg_hash}

    client, auth_cookies = create_client_and_login(endpoint, namespace, username, password, client_id, client_password)

    Rails.logger.info trip_hash.ai
    result = client.call(:pass_create_trip, message: trip_hash, cookies: auth_cookies)
    result.hash
  end

  def pass_create_trip(endpoint, namespace, username, password, para_service_id, client_id, client_password, origin, destination, request_start_seconds_past_midnight, request_end_seconds_past_midnight, offset_minutes, request_date, booking_purpose_id, is_depart, pass1, pass2, pass3, fare1, fare2, fare3, space1, space2, space3)

    pu_address_hash = {address_mode: 'ZZ', street_no: (origin[:street_no] || "").upcase, on_street: (origin[:on_street] || "").upcase, unit: (origin[:unit] || "").upcase, city: (origin[:city] || "").upcase, state: (origin[:state] || "").upcase, zip_code: origin[:zip_code], lat: (origin[:lat]*1000000).to_i, lon: (origin[:lon]*1000000).to_i, geo_status:  -2147483648 }
    if is_depart
      pu_leg_hash = {req_time: [request_start_seconds_past_midnight + (offset_minutes*60), 86399].min, request_address: pu_address_hash}
    else
      pu_leg_hash = {request_address: pu_address_hash}
    end


    do_address_hash = {address_mode: 'ZZ', street_no: (destination[:street_no] || "").upcase, on_street: (destination[:on_street] || "").upcase, unit: (destination[:unit] || "").upcase, city: (destination[:city] || "").upcase, state: (destination[:state] || "").upcase, zip_code: destination[:zip_code], lat: (destination[:lat]*1000000).to_i, lon: (destination[:lon]*1000000).to_i, geo_status:  -2147483648 }
    if is_depart
      do_leg_hash = {request_address: do_address_hash}
    else
      do_leg_hash = {req_time: [request_end_seconds_past_midnight - (offset_minutes*60), 0].max, request_address: do_address_hash}
    end

    trip_hash = {client_id: client_id.to_i, client_code: client_id, date: request_date, booking_type: 'C', para_service_id: para_service_id, auto_schedule: true, calculate_pick_up_req_time: true, booking_purpose_id: booking_purpose_id, pick_up_leg: pu_leg_hash, drop_off_leg: do_leg_hash}

    unless (pass1.blank? and pass2.blank? and pass3.blank?)
      passengers_array = []
      [[pass1, fare1, space1], [pass2, fare2, space2], [pass3, fare3, space3]].each do |pass|
        unless pass[0].blank?
          passengers_array.append(create_passenger_node(pass[0], pass[1], pass[2]))
        end
      end
      trip_hash[:companion_mode] = "S"
      trip_hash[:pass_booking_passengers] = passengers_array
    end

    client, auth_cookies = create_client_and_login(endpoint, namespace, username, password, client_id, client_password)

    funding_source_array = get_funding_source_array(endpoint, namespace, username, password, client_id, client_password)
    final_result = {}
    funding_source_array.each do |funding_source|
      trip_hash[:excluded_validation_checks] = funding_source[:excluded_validation_checks]
      trip_hash[:funding_source_id] = funding_source[:funding_source_id]
      trip_hash[:fare_type_id] = funding_source[:fare_type_id]
      Rails.logger.info trip_hash.ai

      result = client.call(:pass_create_trip, message: trip_hash, cookies: auth_cookies)
      Rails.logger.info result.hash
      result = result.hash
      booking_id = result[:envelope][:body][:pass_create_trip_response][:pass_create_trip_result][:booking_id].to_i
      unless booking_id == -1
        return result
      end
      final_result = result
    end

    return final_result

  end

  def pass_cancel_trip(endpoint, namespace, username, password, client_id, client_password, booking_id)
    client, auth_cookies = create_client_and_login(endpoint, namespace, username, password, client_id, client_password)
    message = {booking_id: booking_id, sched_status: 'CA'}
    result = client.call(:pass_cancel_trip, message: message, cookies: auth_cookies)
    result.hash
  end

  def cancel_trip(endpoint, namespace, username, password, client_id, client_password, booking_id)
    result = pass_cancel_trip(endpoint, namespace, username, password, client_id, client_password, booking_id)

    Rails.logger.info result.ai

    begin
      validation = result[:envelope][:body][:pass_cancel_trip_response][:validation]
      if validation.nil?
        return false
      else
        return confirm_resultok validation
      end
    rescue
      return false
    end

  end

  def pass_get_client_trip(endpoint, namespace, username, password, client_id, client_password, booking_id)
    client, auth_cookies = create_client_and_login(endpoint, namespace, username, password, client_id, client_password)
    message = {booking_id: booking_id}
    result = client.call(:pass_get_client_trips, message: message, cookies: auth_cookies)
    result.hash
  end

  def get_estimated_times(endpoint, namespace, username, password, client_id, client_password, booking_id)
    result = pass_get_client_trip(endpoint, namespace, username, password, client_id, client_password, booking_id)

    Rails.logger.info result.ai


    begin
      pu_leg = result[:envelope][:body][:pass_get_client_trips_response][:pass_get_client_trips_result][:pass_booking][:pick_up_leg]
    rescue
      return {neg_time: nil, neg_early: nil, neg_late: nil}
    end

    neg_time = pu_leg[:neg_time]
    neg_late = pu_leg[:neg_late]
    neg_early = pu_leg[:neg_early]

    return {neg_time: neg_time, neg_early: neg_early, neg_late: neg_late}

  end

  def get_funding_source_array(endpoint, namespace, username, password, client_id, client_password)
    ada_funding_sources = Oneclick::Application.config.ada_funding_sources
    ignore_polygon = Oneclick::Application.config.ignore_polygon_id
    check_polygon = Oneclick::Application.config.check_polygon_id

    funding_source_array = []
    funding_sources = pass_get_client_funding_sources(endpoint, namespace, username, password, client_id, client_password)

    # If this client has 1 funding source returned, the returned object is a json hash.
    # If this client has more than 1 funding source, the returned object is an array of json_hashes
    # Turn all results into an array
    unless funding_sources.kind_of?(Array)
      funding_sources = [funding_sources]
    end

    funding_sources = funding_sources.sort_by{ |fs| fs[:sequence] }

    #First load any ADA Funding Sources
    funding_sources.each do |funding_source|
      if funding_source[:funding_source_name].in? ada_funding_sources
        funding_source_array << {funding_source_id: funding_source[:funding_source_id].to_i, excluded_validation_checks: check_polygon, fare_type_id: Oneclick::Application.config.ada_fare_type}
      end
    end

    #Second load any non-ADA Funding Sources
    funding_sources.each do |funding_source|
      unless funding_source[:funding_source_name].in? ada_funding_sources
        funding_source_array << {funding_source_id: funding_source[:funding_source_id].to_i, excluded_validation_checks: ignore_polygon, fare_type_id: Oneclick::Application.config.non_ada_fare_type}
      end
    end

    Rails.logger.info funding_source_array.ai
    funding_source_array

  end


  def pass_get_passenger_types(endpoint, namespace, username, password, client_id, client_password)
    client, auth_cookies = create_client_and_login(endpoint, namespace, username, password, client_id, client_password)
    message = {client_id: client_id}
    result = client.call(:pass_get_passenger_types, message: message, cookies: auth_cookies)
    result.hash
  end

  def pass_get_space_types(endpoint, namespace, username, password, client_id, client_password)
    client, auth_cookies = create_client_and_login(endpoint, namespace, username, password, client_id, client_password)
    message = {}
    result = client.call(:pass_get_space_types, message: message, cookies: auth_cookies)
    result.hash
  end

  def get_passenger_types(endpoint, namespace, username, password, client_id, client_password)
    result = pass_get_passenger_types(endpoint, namespace, username, password, client_id, client_password)
    return result[:envelope][:body][:pass_get_passenger_types_response][:pass_get_passenger_types_result][:pass_passenger_type]
  end

  def get_space_types(endpoint, namespace, username, password, client_id, client_password)

    result = pass_get_space_types(endpoint, namespace, username, password, client_id, client_password)
    return result[:envelope][:body][:pass_get_space_types_response][:pass_get_space_types_result][:pass_space_type]
  end

  def create_passenger_node(type, fare_type_id, space_type)
    if space_type.blank?
      space_type = "AM"
    end
    return {pass_booking_passenger: {passenger_type: type, space_type: space_type, passenger_count: 1, fare_type: fare_type_id}}
  end

  def pass_get_client_funding_sources(endpoint, namespace, username, password, client_id, client_password)
    client_info = pass_get_client_info(endpoint, namespace, username, password, client_id, client_password)
    client_info[:envelope][:body][:pass_get_client_info_response][:pass_get_client_info_result][:pass_client_funding_sources][:pass_client_funding_source]
  end

  #Pass a validation object and search through it to confirm that the RESULTOK was returned
  def confirm_resultok(validation)
    items = validation[:item]
    items.each do |item|
      if item[:code] == 'RESULTOK'
        return true
      end
    end
    return false
  end

end