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

    client = create_client(endpoint, namespace, username, password)
    response = client.call(:pass_validate_client_password, message: {client_id: client_id, password: client_password})
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

  def pass_create_trip_test(endpoint, namespace, username, password, client_id, client_password)

    #hardcoded for now
    pu_address_hash = {address_mode: 'ZZ', street_num: 100, on_street: "Myrtle Ave N", city: "Jacksonville", state: "FL", zip_code: "32204", lat: (30.330305*1000000).to_i, lon: (-81.677073*1000000).to_i, geo_status:  -2147483648 }
    #pu_address_hash = {address_mode: 'ZZ', addr_name: "JTA", street_num: 100, on_street: "Myrtle Ave N", city: "Jacksonville", state: "FL", zip_code: "32204"}
    pu_leg_hash = {req_time: 36300, request_address: pu_address_hash}

    do_address_hash = {address_mode: 'ZZ', street_num: 22, on_street: "E 3rd St", city: "Jacksonville", state: "FL", zip_code: "32206", lat: (30.339023*1000000).to_i, lon: (-81.653951*1000000).to_i, geo_status:  -2147483648}
    #do_address_hash = {address_mode: 'ZZ', addr_name: "Church", street_num: 22, on_street: "E 3rd St", city: "Jacksonville", state: "FL", zip_code: "32206"}
    do_leg_hash = {request_address: do_address_hash}

    trip_hash = {client_id: 104584, client_code: '104584', date: '20150920', booking_type: 'C', auto_schedule: true, calculate_pick_up_req_time: true, booking_purpose_id: 2, pick_up_leg: pu_leg_hash, drop_off_leg: do_leg_hash}

    client, auth_cookies = create_client_and_login(endpoint, namespace, username, password, client_id, client_password)

    Rails.logger.info trip_hash.ai
    result = client.call(:pass_create_trip, message: trip_hash, cookies: auth_cookies)
    result.hash
  end

  def pass_create_trip(endpoint, namespace, username, password, client_id, client_password, origin, destination, request_seconds_past_midnight, request_date)

    #hardcoded for now
    pu_address_hash = {address_mode: 'ZZ', street_num: origin[:street_num], on_street: origin[:on_street], city: origin[:city], state: origin[:state], zip_code: origin[:zip_code], lat: (origin[:lat]*1000000).to_i, lon: (origin[:lon]*1000000).to_i, geo_status:  -2147483648 }
    pu_leg_hash = {req_time: request_seconds_past_midnight, request_address: pu_address_hash}

    do_address_hash = {address_mode: 'ZZ', street_num: destination[:street_num], on_street: destination[:on_street], city: destination[:city], state: destination[:state], zip_code: destination[:zip_code], lat: (destination[:lat]*1000000).to_i, lon: (destination[:lon]*1000000).to_i, geo_status:  -2147483648 }
    do_leg_hash = {request_address: do_address_hash}

    trip_hash = {client_id: client_id.to_i, client_code: client_id, date: request_date, booking_type: 'C', auto_schedule: true, calculate_pick_up_req_time: true, booking_purpose_id: 2, pick_up_leg: pu_leg_hash, drop_off_leg: do_leg_hash}

    client, auth_cookies = create_client_and_login(endpoint, namespace, username, password, client_id, client_password)

    Rails.logger.info trip_hash.ai
    result = client.call(:pass_create_trip, message: trip_hash, cookies: auth_cookies)
    result.hash
  end

  def pass_cancel_trip(endpoint, namespace, username, password, client_id, client_password, booking_id)
    client, auth_cookies = create_client_and_login(endpoint, namespace, username, password, client_id, client_password)
    message = {booking_id: booking_id, sched_status: 'CA'}
    result = client.call(:pass_cancel_trip, message: message, cookies: auth_cookies)
    result.hash
  end

  def cancel_trip(endpoint, namespace, username, password, client_id, client_password, booking_id)
    result = pass_cancel_trip(endpoint, namespace, username, password, client_id, client_password, booking_id)

    begin
      cancellation_number = result[:envelope][:body][:pass_cancel_trip_response][:pass_cancel_trip_result][:cancellation_number]
      unless cancellation_number.nil?
        return true
      else
        return false
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


end