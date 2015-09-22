
class TrapezeHelpers

  ########## BEGIN Setup client and authorize ###############
  def create_client

    client = Savon.client do
      endpoint "http://74.252.99.60:8081/PassInfoServer"
      namespace "http://74.252.99.60:8081/PassInfoServer"
      basic_auth ["Trapeze", "trapeze"]
      convert_request_keys_to :camelcase
    end

    return client

  end

  def login(client_id, password, client)

    result = client.call(:pass_validate_client_password, message: {client_id: client_id, password: password})
    auth_cookies = result.http.cookies

    return auth_cookies

  end

  def create_client_and_login(client_id, password)

    client = create_client
    auth_cookies = login(client_id, password, client)

    return client, auth_cookies

  end

  ########## END Setup client and authorize ###############

  def pass_get_client_info(client_id, password)

    client, auth_cookies = create_client_and_login(client_id, password)
    result = client.call(:pass_get_client_info, message: {client_id: client_id}, cookies: auth_cookies)
    result.hash

  end

  def pass_get_client_trips(client_id, password)

    client, auth_cookies = create_client_and_login(client_id, password)
    result = client.call(:pass_get_client_trips, message: {client_id: client_id}, cookies: auth_cookies)
    result.hash

  end

  def pass_get_schedules (client_id, password)
    client, auth_cookies = create_client_and_login(client_id, password)
    result = client.call(:pass_get_schedules, cookies: auth_cookies)
    result.hash
  end

  def pass_create_trip(client_id, password)

    #hardcoded for now
    pu_address_hash = {addr_name: "JTA", street_num: 100, on_street: "Myrtle Ave N", city: "Jacksonville", state: "FL", zip_code: "32204", lat: (30.330305*1000000).to_i, lon: (-81.677073*1000000).to_i  }
    pu_leg_hash = {req_time: 36300, request_address: pu_address_hash}

    do_address_hash = {addr_name: "Church", street_num: 22, on_street: "E 3rd St", city: "Jacksonville", state: "FL", zip_code: "32206", lat: (30.339023*1000000).to_i, lon: (-81.653951*1000000).to_i  }
    do_leg_hash = {request_address: do_address_hash}

    trip_hash = {client_id: 104584, client_code: '104584', date: '20150902', booking_type: 'C', pick_up_leg: pu_leg_hash, drop_off_leg: do_leg_hash}

    client, auth_cookies = create_client_and_login(client_id, password)

    puts trip_hash.ai
    result = client.call(:pass_create_trip, message: trip_hash, cookies: auth_cookies)
  end


end