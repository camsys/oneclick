require 'net/http'
require 'openssl'
require 'indirizzo'

class EcolaneServices

  begin
    BASE_URL = Oneclick::Application.config.ecolane_base_url
  rescue NoMethodError
    BASE_URL = nil
  end

  ################################################################################
  ## Customer Info and Search
  ################################################################################

  # Ecolane users two identifiers for each customer.
  # This takes in a customer_number (the number that the passenger knows)
  # and converts to a customer_id (the database id for that passenger)
  def get_customer_id(customer_number, system, token)
    resp = search_for_customers(system, token, customer_number: customer_number)
    resp_xml = Nokogiri::XML(resp.body)

    status = resp_xml.xpath("status")
    unless status.empty?
      if status.attribute("result").value == "failure"
        return nil
      end
    end

    if resp_xml.xpath("search_results").xpath("customer").count == 1
      ecolane_customer_id = resp_xml.xpath("search_results").xpath("customer").first.attribute("id").value
      return ecolane_customer_id
    else
      return nil
    end
  end

  # Parses an ecolane search response into an array of customer hashes
  def parse_customer_query_array(response)
    resp = Hash.from_xml(response.body)
    customer = (resp["search_results"] && resp["search_results"]["customer"]) || [] # Return an empty array if there are no results
    return customer.class == Array ? customer : [customer] # If a single hash is returned, pack into an array
  end

  # Returns Ecolane customer number (not id) based on ssn, last name, and county system name.
  def query_customer_number(system, token, params={})
    resp = search_for_customers(system, token, params)
    return nil unless resp.code[0] == "2" # Return nil if get a failure (non-2xx code) HTML response
    customers = parse_customer_query_array(resp).select do |customer| # select only responses that match ssn
      customer["ssn"] && customer["ssn"].last(4) == params[:ssn_last_4].to_s
    end
    return customers.count == 1 ? customers.first["customer_number"] : nil # Return nil if not exactly one result
  end

  # Get orders for a customer
  def fetch_customer_orders(customer_id, system_id, token)
    url_options = "/api/customer/" + system_id + '/'
    url_options += customer_id.to_s
    url_options += "/orders"
    url = BASE_URL + url_options
    send_request(url, token)
  end

  # Get a list of trip purposes for a customer
  def get_trip_purposes(customer_id, system_id, token, disallowed_purposes)
    purposes = []
    customer_information = fetch_customer_information(customer_id, system_id, token, funding = true)
    resp_xml = Nokogiri::XML(customer_information)
    resp_xml.xpath("customer").xpath("funding").xpath("funding_source").each do |funding_source|
      funding_source.xpath("allowed").each do |allowed|
        purpose = allowed.xpath("purpose").text
        unless purpose.in? purposes or purpose.downcase.strip.in? (disallowed_purposes.map { |p| p.downcase.strip } || "")
          purposes.append(purpose)
        end
      end

    end
    purposes.sort
  end

  # Get customer information from ID
  # If funding=true, return funding_info
  # If locations=true return a list of the clients locations (e.g., home)
  def fetch_customer_information(customer_id, system_id, token, funding=false, locations=false)
    url_options = "/api/customer/" + system_id.to_s + '/'
    url_options += customer_id.to_s
    url_options += "?funding=" + funding.to_s + "&locations=" + locations.to_s
    url = BASE_URL + url_options
    Rails.logger.debug URI.parse(url)
    t = Time.now
    resp = send_request(url, token )
    if resp.code != "200"
      return false, {'id'=>resp.code.to_i, 'msg'=>resp.message}
    end
    resp.body
  end

  # Get a list of customers
  def search_for_customers(system, token, terms = {})
    url_options = "/api/customer/" + system.to_s + '/search?'
    terms.each do |term|
      url_options += "&" + term[0].to_s + '=' + term[1].to_s
    end
    url = Oneclick::Application.config.ecolane_base_url + url_options
    send_request(url, token)
  end

  # Check to see if a passenger's DOB matches
  def validate_passenger(customer_number, dob, system_id, token)

    iso_dob = iso8601ify(dob)
    if iso_dob.nil?
      return false, "", ""
    end
    resp = search_for_customers(system_id, token, {"customer_number" => customer_number, "date_of_birth" => iso_dob.to_s})
    resp = unpack_validation_response(resp)
    return resp[0], resp[2][0], resp[2][1]
  end

  # Unpack the validate_passenger call
  def unpack_validation_response (resp)
    resp_xml = Nokogiri::XML(resp.body)
    status = resp_xml.xpath("status")
    #On success, status = []
    unless status.empty?
      if status.attribute("result").value == "failure"
        return false, "Unable to validate Client Id"
      end
    end

    if resp_xml.xpath("search_results").xpath("customer").count == 1
      first_name = resp_xml.xpath("search_results").xpath("customer")[0].xpath("first_name").text
      last_name = resp_xml.xpath("search_results").xpath("customer")[0].xpath("last_name").text
      return true, "Success!", [first_name, last_name]
    else
      return false, "Invalid Date of Birth or Client Id.", ['', '']
    end
  end

  # Return a passenger's home address.  Used the first time a passenger logs in
  def get_passenger_home(customer_number, system_id, token)
    customer_id = get_customer_id(customer_number, system_id, token)
    passenger_xml = fetch_customer_information(customer_id, system_id, token, funding=false, locations=true)
    passenger_hash = Hash.from_xml(passenger_xml)

    #Unpack one at a time, return if any information is nil
    customer = passenger_hash['customer']
    unless customer
      return nil
    end

    locations = customer['locations']
    unless locations
      return nil
    end

    locations = locations['location']
    unless locations
      return nil
    end

    # If there is only one locations, it comes back as a single element instead of an array
    # Ensure that we always get an array
    unless locations.kind_of?(Array)
      locations = [locations]
    end

    possible_home = nil
    locations.each do |location|
      if location['type'].downcase == 'home'
        return location
      end
      if location['name']
        if location['name'].downcase == 'home'
          possible_home = location
        end
      end
    end

    return possible_home

  end

  ################################################################################
  ## Booking
  ################################################################################

  # Books Trip (funding_source and sponsor must be specified)
  def book_itinerary_v9 params
    url_options = "/api/order/" + params[:system] + "?overlaps=reject"
    url = BASE_URL + url_options
    order =  build_order_v9 params
    order = Nokogiri::XML(order)
    order.children.first.set_attribute('version', '3')
    order = order.to_s
    resp = send_request(url, params[:token], 'POST', order)
    Rails.logger.info('Order Request Sent to Ecolane:')
    Rails.logger.info(order)
    return unpack_booking_response(resp)
  end

  # Convert the booking message from an xml to a boolean and a message
  # If the trip booking is successful, the boolean is true and the message is the confirmation number for the trip
  # If the trip is not not successful, the boolean is false and the message is an error message
  def unpack_booking_response(resp)
    begin
      resp_xml = Nokogiri::XML(resp.body)
    rescue
      Rails.logger.debug "Booking error #004"
      return false, "Booking error."
    end
    status = resp_xml.xpath("status")
    unless status.count == 0
      status = status.attribute('result').value
    else
      return false, "Server error."
    end

    messages = ""
    case status
      when "failure"
        begin
          resp_xml.xpath("status").xpath("error").each do |error|
            messages << error.xpath("message").text
            messages << " "
          end
        rescue
          Rails.logger.debug "Booking error #001"
          return false, "Unknown response #001"
        end
        Rails.logger.debug "Booking error #005"
        Rails.logger.debug messages
        return false, messages

      when "success"

        begin
          confirmation = resp_xml.xpath("status").xpath("success").attribute('resource_id').value
          messages << confirmation.to_s
        rescue
          Rails.logger.debug "Booking error #002"
          return false, "Unknown response #002"
        end

        return true, messages
    end
    return false, "Unknown response."
  end

  ################################################################################
  ## Fetch Orders and Trip Info
  ################################################################################

  # Return a hash of all upcoming trips
  def get_future_orders customer_number, system, token
    customer_id = get_customer_id(customer_number, system, token)
    url_options = "/api/customer/" + system + '/'
    url_options += customer_id.to_s
    url_options += "/orders"
    url_options += "?start=" + Time.now.iso8601[0...-6]
    url = BASE_URL + url_options
    response = send_request(url, token)
    unpack_orders(response)
  end

  # Return a Hash of previous Trips
  def get_past_orders(customer_number, max_results, end_time, system, token)
    customer_id = get_customer_id(customer_number, system, token)
    url_options = "/api/customer/" + system + '/'
    url_options += customer_id.to_s
    url_options += "/orders"
    url_options += "?end=" + end_time[0...-6]
    url_options += "&limit=" + (max_results || 10).to_s
    url = BASE_URL + url_options

    response = send_request(url, token)
    unpack_orders(response)
  end

  # Unpack the Response from the Future/Past Orders Call
  def unpack_orders response

    begin
      resp_code = response.code
    rescue
      return false, "500"
    end

    unless resp_code == "200"
      return false, response.message
    end

    body = Hash.from_xml(response.body)

    orders = body['orders']

    if orders.nil?
      return []
    end

    #If orders is not nil, pull out the orders array
    orders = body['orders']['order']

    #Ecolane will not return an array of only one object, so make it an array
    unless orders.is_a? Array
      orders = [orders]
    end

    orders

  end

  # Given a booking_confirmation, returns the current info of this trip (pu_time, do_time, confirmation_number)
  def get_trip_info(booking_confirmation, system, token)
    resp = fetch_single_order(booking_confirmation, system, token)
    return unpack_fetch_single(resp, booking_confirmation)
  end

  # Utility function used to parse the result of get_trip_info
  def unpack_fetch_single (resp, confirmation)
    begin
      resp_code = resp.code
    rescue
      return false, "500"
    end

    unless resp_code == "200"
      return false, resp.message
    end

    resp_xml = Nokogiri::XML(resp.body)
    pu_time = DateTime.xmlschema(resp_xml.xpath("order").xpath("pickup").xpath("negotiated").text).strftime("%b %e, %l:%M %p")

    begin
      do_time = DateTime.xmlschema(resp_xml.xpath("order").xpath("dropoff").xpath("negotiated").text).strftime("%b %e, %l:%M %p")
    rescue
      do_time = nil
    end

    return true, {pu_time: pu_time, do_time: do_time, confirmation: confirmation}

  end

  # Gets the status of the trip.  Used to see if a trip is canceled or not
  def get_trip_status(trip_id, system_id, token)
    resp = fetch_single_order(trip_id, system_id, token)
    begin
      resp_code = resp.code
    rescue
      return nil
    end
    unless resp_code == "200"
      return nil
    end
    resp_xml = Nokogiri::XML(resp.body)
    resp_xml.xpath("order").xpath("status").text
  end

  def fetch_single_order(trip_id, system_id, token)
    url_options = "/api/order/" + system_id + '/'
    url_options += trip_id.to_s
    url = BASE_URL + url_options
    send_request(url, token)
  end

  # Returns true if this trip belongs to that customer_number
  def trip_belongs_to_user? params
    resp = fetch_single_order(params[:booking_confirmation], params[:system], params[:token])
    body = Hash.from_xml(resp.body)
    customer_id_from_trip = body["order"]["customer_id"]
    customer_id = get_customer_id(params[:customer_number], params[:system], params[:token])
    return customer_id_from_trip == customer_id
  end

  ################################################################################
  ## Query Fares and Discounts
  ################################################################################

  # Description:
  # Find the fare for a trip. (Used in v9 of the API)
  def query_preferred_fare params
    sponsors = nil
    url_options =  "/api/order/" + params[:system] + "/query_preferred_fares"
    url = BASE_URL + url_options

    funding = {purpose: params['trip_purpose_raw']}
    params[:funding] = funding

    order =  build_order_v9 params
    order = Nokogiri::XML(order)
    order.children.first.set_attribute('version', '3')
    order = order.to_s
    resp = send_request(url, params[:token], 'POST', order)

    begin
      resp_code = resp.code
    rescue
      return false, "500"
    end

    if resp_code != "200"
      return false, {'id'=>resp_code.to_i, 'msg'=>resp.message}
    end
    fare, funding_source, sponsor = unpack_fare_response_v9(resp)
    return true, {fare: fare, funding_source: funding_source, sponsor: sponsor}
  end

  # Unpack fare response from query_preferred_fare_call.  Return the Fare with the HIGHEST (Largest Number) Priority
  def unpack_fare_response_v9 (resp)
    fare_hash = Hash.from_xml(resp.body)

    fares = fare_hash['fares']['fare']

    highest_priority_fare = []

    #When there is only one option in the fares table, it is  not returned as an array.  Turn it into an array
    unless fares.kind_of? Array
      fares = [fares]
    end

    fares.each do |fare|
      if highest_priority_fare.empty? or highest_priority_fare[3] < fare['priority']
        highest_priority_fare = [fare['client_copay'], fare['funding']['funding_source'], fare['funding']['sponsor'], fare['priority']]
      end
    end
    return highest_priority_fare[0], highest_priority_fare[1], highest_priority_fare[2]
  end

  # For anonymous user, get an array of potential prices and funding sources
  def build_discount_array_v9 params
    url_options =  "/api/order/" + params[:system] + "/query_preferred_fares"
    url = BASE_URL + url_options
    params[:funding] = {}

    order =  build_order_v9 params
    order = Nokogiri::XML(order)
    order.children.first.set_attribute('version', '3')
    order = order.to_s
    resp = send_request(url, params[:token], 'POST', order)

    begin
      resp_code = resp.code
    rescue
      return false, "500"
    end

    if resp_code != "200"
      return false, {'id'=>resp_code.to_i, 'msg'=>resp.message}
    end

    #Fare, Funding_Source, Comment

    unpack_build_discount_array_v9 resp

    #fare, funding_source, sponsor = unpack_fare_response_v9(resp)
    #return true, {fare: fare, funding_source: funding_source, sponsor: sponsor}

  end

  # Unpack build discounts call
  def unpack_build_discount_array_v9 (resp)
    temp_hash = {}
    fare_hash = Hash.from_xml(resp.body)
    fares = fare_hash['fares']['fare']
    fares.each do |fare|
      new_funding_source = fare["funding"]["funding_source"]
      new_fare = fare["client_copay"].to_f/100
      new_comment = fare["funding"]["description"]

      current = temp_hash[new_funding_source]

      #If this is the first time seeing this funding source, save it.
      if current.nil?
        if not new_comment.nil? and not new_fare.nil?
          temp_hash[new_funding_source] = {fare: new_fare, comment: new_comment}
        end
      #If we've seen this funding source before, but the new fare is higher, save it.
      elsif current[:fare] < new_fare
        if not new_comment.nil? and not new_fare.nil?
          temp_hash[new_funding_source] = {fare: new_fare, comment: new_comment}
        end
      end
    end

    discounts = []
    temp_hash.each do |k,v|
      v[:funding_source] = k
      discounts << v
    end

    return discounts
    #funding_source = fare_hash['fares'] ['fare']['funding']['funding_source']
    #sponsor= fare_hash['fares'] ['fare']['funding']['sponsor']
    #return fare, funding_source, sponsor
  end

  ################################################################################
  ## Cancel Trip
  ################################################################################

  # Cancel a Trip
  def cancel params
    url_options = "/api/order/" + params[:system] + '/'
    url_options += params[:confirmation_number].to_s
    url = Oneclick::Application.config.ecolane_base_url + url_options
    resp = send_request(url, params[:token], 'DELETE')

    begin
      resp_code = resp.code
    rescue
      return false
    end

    if resp_code == "200"
      Rails.logger.debug "Trip " + params[:confirmation_number].to_s + " canceled."
      #The trip was successfully canceled
      return true
    elsif get_trip_status(params[:confirmation_number], params[:system], params[:token]) == 'canceled'
      Rails.logger.debug "Trip " + params[:confirmation_number].to_s + " already canceled."

      #The trip was not successfully deleted, because it was already canceled
      return true
    else
      Rails.logger.debug "Trip " + params[:confirmation_number].to_s + " cannot be canceled."
      #The trip is not canceled
      return false
    end

  end


  ################################################################################
  ## Utility functions
  ################################################################################


  # Description
  # Builds an order without searching through funding sources/sponsors
  def build_order_v9 params

    order_hash = {assistant: yes_or_no(params[:assistant]), companions: params[:companions], children: params[:children], other_passengers: params[:other_passengers], pickup: build_pu_hash(params[:is_depart], params[:scheduled_time], params[:from_trip_place], params[:note_to_driver]), dropoff: build_do_hash(params[:is_depart], params[:scheduled_time], params[:to_trip_place])}

    if params[:customer_number]
      order_hash[:customer_id] = get_customer_id(params[:customer_number], params[:system], params[:token])
    end

    funding_hash = {}
    if params[:trip_purpose_raw]
      funding_hash[:purpose] = params[:trip_purpose_raw]
    end
    if params[:funding_source]
      funding_hash[:funding_source] = params[:funding_source]
    end
    if params[:sponsor]
      funding_hash[:sponsor] = params[:sponsor]
    end
    order_hash[:funding] = funding_hash

    order_xml = order_hash.to_xml(root: 'order', :dasherize => false)
    order_xml
  end

  #Build the hash for the pickup request
  def build_pu_hash(is_depart, scheduled_time, from_trip_place, note_to_driver)
    if is_depart
      pu_hash = {requested: scheduled_time.xmlschema.chop.chop.chop.chop.chop.chop, location: build_location_hash(from_trip_place), note: note_to_driver}
    else
      pu_hash = {location: build_location_hash(from_trip_place), note: note_to_driver}
    end
    pu_hash
  end

  #Build the hash for the drop off request
  def build_do_hash(is_depart, scheduled_time, to_trip_place)
    if is_depart
      do_hash = {location: build_location_hash(to_trip_place)}
    else
      do_hash = {requested: scheduled_time.xmlschema.chop.chop.chop.chop.chop.chop, location: build_location_hash(to_trip_place)}
    end
    do_hash
  end

  #Build a location hash (Used for dropoffs and pickups )
  def build_location_hash(place)
    street_number, street = if place['address1'].present?
                              parsable_address = Indirizzo::Address.new(place['address1'])
                              [parsable_address.number, parsable_address.street.first]
                            end

    {street_number: street_number, street: street, city: place['city'], state: place['state'], zip: place['zip'], latitude: place['lat'], longitude: place['lon']}
  end

  ## Send the Requests
  def send_request(url, token, type='GET', message=nil)

    Rails.logger.info("Sending Request . . .")

    url.sub! " ", "%20"

    Rails.logger.info("URL")
    Rails.logger.info(url)
    Rails.logger.info("MESSAGE")
    Rails.logger.info(message)

    begin
      uri = URI.parse(url)
      case type.downcase
        when 'post'
          req = Net::HTTP::Post.new(uri.path)
          req.body = message
        when 'delete'
          req = Net::HTTP::Delete.new(uri.path)
        else
          req = Net::HTTP::Get.new(uri)
      end

      req.add_field 'X-ECOLANE-TOKEN', token
      req.add_field 'X-Ecolane-Agent', 'ococtest'
      req.add_field 'Content-Type', 'text/xml'

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      resp = http.start {|http| http.request(req)}
      Rails.logger.info("REQ")
      Rails.logger.info(req.inspect)
      Rails.logger.info("RESPONSE")
      Rails.logger.info(resp.body)
      Rails.logger.info("End")
      return resp
    rescue Exception=>e
      Rails.logger.info("Sending Error")
      return false, {'id'=>500, 'msg'=>e.to_s}
    end
  end

  def iso8601ify(dob)

    dob = dob.split('/')
    unless dob.count == 3
      return nil
    end

    begin
      dob = Date.parse(dob[1] + '/' + dob[0] + '/' + dob[2]).strftime("%Y/%m/%d")
    rescue  ArgumentError
      return nil
    end

    Date.iso8601(dob.delete('/'))
  end

  def yes_or_no value
    value.to_bool ? true : false
  end

  ################################################################################################
  ##
  ## Deprecated Methods: These methods were are used in Ecolane v8 and prior.  They are used to calculate Funding Sources and Sponsors
  ##
  ################################################################################################

  # Books Trip (used prior to v9 ecolane update.  Funding Source and Sponsors are calculated using 1-Click Logic)
  def book_itinerary(sponsors, trip_purpose_raw, is_depart, scheduled_time, from_trip_place, to_trip_place, note_to_driver, assistant, companions, children, other_passengers, customer_number, funding_array, system, token)
    begin
      funding_options = query_funding_options(sponsors, trip_purpose_raw, is_depart, scheduled_time, from_trip_place, to_trip_place, note_to_driver, assistant, companions, children, other_passengers, customer_number, system, token)
      funding_xml = Nokogiri::XML(funding_options.body)
      Rails.logger.info(funding_xml)
    rescue
      Rails.logger.debug "Booking error #003"
      return false, "Booking error."
    end
    resp = request_booking(sponsors, trip_purpose_raw, is_depart, scheduled_time, from_trip_place, to_trip_place, note_to_driver, assistant, companions, children, other_passengers, customer_number, funding_xml, funding_array, system, token)
    return unpack_booking_response(resp)
  end

  # Builds the booking request and sends it to Ecolane
  def request_booking(sponsors, trip_purpose_raw, is_depart, scheduled_time, from_trip_place, to_trip_place, note_to_driver, assistant, companions, children, other_passengers, customer_number, funding_xml, funding_array, system, token)
    url_options = "/api/order/" + system + "?overlaps=reject"
    url = BASE_URL + url_options
    order =  build_order(sponsors, trip_purpose_raw, is_depart, scheduled_time, from_trip_place, to_trip_place, note_to_driver, assistant, companions, children, other_passengers, customer_number, system, token, funding_xml, funding_array)
    order = Nokogiri::XML(order)
    order.children.first.set_attribute('version', '3')
    order = order.to_s
    result  = send_request(url, token, 'POST', order)
    Rails.logger.info('Order Request Sent to Ecolane:')
    Rails.logger.info(order)
    result
  end

  # Checks on an itineraries funding options and sends the request to Ecolane
  def query_funding_options(sponsors, trip_purpose_raw, is_depart, scheduled_time, from_trip_place, to_trip_place, note_to_driver, assistant, companions, children, other_passengers, customer_number, system, token, funding_xml=nil, funding_array=nil)
    url_options = "/api/order/" + system + '/queryfunding'
    url = BASE_URL + url_options
    order =  build_order(sponsors, trip_purpose_raw, is_depart, scheduled_time, from_trip_place, to_trip_place, note_to_driver, assistant, companions, children, other_passengers, customer_number, system, token, funding_xml, funding_array)
    order = Nokogiri::XML(order)
    order.children.first.set_attribute('version', '3')
    order = order.to_s
    send_request(url, token, 'POST', order)
  end

  # Description:
  # Find the fare for a trip.
  def query_fare params

    url_options =  "/api/order/" + params[:system] + "/queryfare"
    url = BASE_URL + url_options
    funding_options = query_funding_options(params[:sponsors], params[:trip_purpose_raw], params[:is_depart], params[:scheduled_time], params[:from_trip_place], params[:to_trip_place], note_to_driver="", assistant=false, companions=0, children=0, other_passengers=0, params[:customer_number], params[:system], params[:token])
    funding_xml = Nokogiri::XML(funding_options.body)
    Rails.logger.info("Begin Funding info")
    Rails.logger.info(funding_xml)
    Rails.logger.info("End Funding info")
    order =  build_order(params[:sponsors], params[:trip_purpose_raw], params[:is_depart], params[:scheduled_time], params[:from_trip_place], params[:to_trip_place], note_to_driver="", assistant=false, companions=0, children=0, other_passengers=0, params[:customer_number], params[:system], params[:token], funding_xml, params[:funding_array])
    order = Nokogiri::XML(order)
    order.children.first.set_attribute('version', '3')
    order = order.to_s
    resp = send_request(url, params[:token], 'POST', order)

    begin
      resp_code = resp.code
    rescue
      return false, "500"
    end

    if resp_code != "200"
      return false, {'id'=>resp_code.to_i, 'msg'=>resp.message}
    end
    fare = unpack_fare_response(resp)
    return true, fare
  end

  # Unpack fare response from query_fare_call
  def unpack_fare_response (resp)
    resp_xml = Nokogiri::XML(resp.body)
    Rails.logger.info(resp_xml)
    client_copay = resp_xml.xpath("fare").xpath("client_copay").text
    return client_copay.to_f/100.0
  end

  def build_discount_order(sponsors, trip_purpose, customer_number, customer_id, assistant, companions, children, other_passengers, is_depart, scheduled_time, to_trip_place, from_trip_place, funding_source, system, token)
    order_hash = build_discount_order_hash(sponsors, trip_purpose, customer_id, customer_number, assistant, companions, children, other_passengers, is_depart, scheduled_time, to_trip_place, from_trip_place, funding_source, system, token)
    order_xml = order_hash.to_xml(root: 'order', :dasherize => false)
    order_xml
  end

  def build_discount_order_hash(sponsors, trip_purpose, customer_number, customer_id, assistant, companions, children, other_passengers, is_depart, scheduled_time, to_trip_place, from_trip_place, funding_source, system, token)
    order = {customer_id: customer_id, assistant: yes_or_no(assistant), companions: companions, children: children, other_passengers: other_passengers, pickup: build_pu_hash(is_depart, scheduled_time, from_trip_place, note_to_driver=""), dropoff: build_do_hash(is_depart, scheduled_time, to_trip_place)}
    funding_options = query_funding_options(sponsors, trip_purpose, is_depart, scheduled_time, from_trip_place, to_trip_place, note_to_driver="", assistant, companions, children, other_passengers, customer_number, system, token)
    funding_xml = Nokogiri::XML(funding_options.body)
    order[:funding] = build_funding_hash_from_funding_source(sponsors, trip_purpose, funding_source, funding_xml)
    order
  end

  def build_discount_array(funding_sources, sponsors, trip_purpose, customer_number, customer_id, assistant, companions, children, other_passengers, is_depart, scheduled_time, to_trip_place, from_trip_place, system, token)
    url_options =  "/api/order/" + system + "/queryfare"
    url = Oneclick::Application.config.ecolane_base_url + url_options

    #First: Find Gen Public Fare
    discount_array = []
    Rails.logger.info "Number of funding sources to try: " + funding_sources.count.to_s

    funding_sources.each do |funding_source|
      Rails.logger.info(funding_source['code'])

      funding_source_code = funding_source['code']
      order = build_discount_order(sponsors, trip_purpose, customer_id, customer_number, assistant, companions, children, other_passengers, is_depart, scheduled_time, to_trip_place, from_trip_place, funding_source_code, system, token)
      order = Nokogiri::XML(order)
      order.children.first.set_attribute('version', '3')
      order = order.to_s
      resp = send_request(url, token, 'POST', order)

      begin
        resp_code = resp.code
      rescue
        resp_code = nil
      end

      if resp_code == "200"
        fare = unpack_fare_response(resp)
        discount_array.append({fare: fare, comment: funding_source['comment'], funding_source: funding_source['code'], base_fare: funding_source['general_public']})
      end
    end

    discount_array
  end

  ## Building hash objects that become XML nodes
  def build_order(sponsors, trip_purpose_raw, is_depart, scheduled_time, from_trip_place, to_trip_place, note_to_driver, assistant, companions, children, other_passengers, customer_number, system, token, funding_xml=nil, funding_array=nil)
    order_hash = build_order_hash(sponsors, trip_purpose_raw, is_depart, scheduled_time, from_trip_place, to_trip_place, note_to_driver, assistant, companions, children, other_passengers, customer_number, system, token, funding_xml, funding_array)
    order_xml = order_hash.to_xml(root: 'order', :dasherize => false)
    order_xml
  end

  def build_order_hash(sponsors, trip_purpose_raw, is_depart, scheduled_time, from_trip_place, to_trip_place, note_to_driver, assistant, companions, children, other_passengers, customer_number, system, token, funding_xml=nil, funding_array=nil)
    order = {
      customer_id: get_customer_id(customer_number, system, token),
      assistant: yes_or_no(assistant),
      companions: companions,
      children: children,
      other_passengers: other_passengers,
      pickup: build_pu_hash(is_depart, scheduled_time, from_trip_place, note_to_driver),
      dropoff: build_do_hash(is_depart, scheduled_time, to_trip_place)
    }
    if funding_xml
      order[:funding] = build_funding_hash(sponsors, trip_purpose_raw, funding_xml, funding_array)
    end
    Rails.logger.info(order)
    order
  end

  def build_funding_hash(sponsors, purpose, funding_xml, funding_array)
    min_index = 10000
    best_funding_source = nil

    #Cycle through all the funding sources for this trip.  Return the one with the lowest index.
    funding_xml.xpath("funding_options").xpath("option").each do |options|

      ecolane_purpose = options.xpath("purpose").text

      if ecolane_purpose == purpose
        funding_source = options.xpath("funding_source").text
        index = funding_array.index(funding_source)

        if index and (index < min_index)
          min_index = index
          best_funding_source = funding_source

          #If we match the default funding source, go ahead and find the purpose
          if min_index == 0
            return build_funding_hash_from_funding_source(sponsors, purpose, best_funding_source, funding_xml)
          end

        end

      end
    end

    return build_funding_hash_from_funding_source(sponsors, purpose, best_funding_source, funding_xml)

  end

  def build_funding_hash_from_funding_source(sponsors, purpose, funding_source, funding_xml)

    if sponsors.count == 0
      return {funding_source: funding_source, purpose: purpose, sponsor: nil}
    end

    min_index = 10000
    best_sponsor = nil

    #Cycle through all the funding sources for this trip.  For the one's that match our funding source, find the best sponsor
    funding_xml.xpath("funding_options").xpath("option").each do |options|
      ecolane_funding_source = options.xpath("funding_source").text

      unless ecolane_funding_source == funding_source
        next
      end

      ecolane_purpose = options.xpath("purpose").text

      if ecolane_purpose == purpose

        sponsor = options.xpath("sponsor").text
        index_of_sponsor = sponsors.index(sponsor)

        if best_sponsor.nil?
          best_sponsor = sponsor
          min_index = index_of_sponsor || min_index
        elsif index_of_sponsor and index_of_sponsor < min_index
          best_sponsor = sponsor
          min_index = index_of_sponsor
        end

        #If we match the default funding source with the min sponsor, go ahead and return.
        if min_index == 0
          return {funding_source: funding_source, purpose: purpose, sponsor: best_sponsor}
        end
      end
    end

    return {funding_source: funding_source, purpose: purpose, sponsor: best_sponsor}

  end

end
