require 'net/http'
require 'openssl'
require 'indirizzo'

class EcolaneServices

  begin
    BASE_URL = Oneclick::Application.config.ecolane_base_url
  rescue NoMethodError
    BASE_URL = nil
  end

  #OK
  def get_customer_id(customer_number, system, token)
    resp = search_for_customers(terms = {customer_number: customer_number}, system, token)
    resp_xml = Nokogiri::XML(resp.body)

    status = resp_xml.xpath("status")
    #On success, status = []
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

  ## Post/Put Operations
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

  def get_trip_info(itinerary)
    unless itinerary.service
      return false, '500'
    end
    resp = fetch_single_order(itinerary.booking_confirmation, itinerary.service.booking_system_id, itinerary.service.booking_token)
    return unpack_fetch_single(resp, itinerary.booking_confirmation)

  end

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

  def request_booking(sponsors, trip_purpose_raw, is_depart, scheduled_time, from_trip_place, to_trip_place, note_to_driver, assistant, companions, children, other_passengers, customer_number, funding_xml, funding_array, system, token)
    url_options = "/api/order/" + system + "?overlaps=reject"
    url = BASE_URL + url_options
    order =  build_order(sponsors, trip_purpose_raw, is_depart, scheduled_time, from_trip_place, to_trip_place, note_to_driver, assistant, companions, children, other_passengers, customer_number, system, token, funding_xml, funding_array)
    order = Nokogiri::XML(order)
    order.children.first.set_attribute('version', '2')
    order = order.to_s
    result  = send_request(url, token, 'POST', order)
    Rails.logger.info('Order Request Sent to Ecolane:')
    Rails.logger.info(order)
    result
  end

  def query_funding_options(sponsors, trip_purpose_raw, is_depart, scheduled_time, from_trip_place, to_trip_place, note_to_driver, assistant, companions, children, other_passengers, customer_number, system, token, funding_xml=nil, funding_array=nil)
    url_options = "/api/order/" + system + '/queryfunding'
    url = BASE_URL + url_options
    order =  build_order(sponsors, trip_purpose_raw, is_depart, scheduled_time, from_trip_place, to_trip_place, note_to_driver, assistant, companions, children, other_passengers, customer_number, system, token, funding_xml, funding_array)
    order = Nokogiri::XML(order)
    order.children.first.set_attribute('version', '2')
    order = order.to_s
    send_request(url, token, 'POST', order)
  end

  def query_fare(sponsors, trip_purpose_raw, is_depart, scheduled_time, from_trip_place, to_trip_place, customer_number, system, token, funding_array)

    url_options =  "/api/order/" + system + "/queryfare"
    url = BASE_URL + url_options
    funding_options = query_funding_options(sponsors, trip_purpose_raw, is_depart, scheduled_time, from_trip_place, to_trip_place, note_to_driver="", assistant=false, companions=0, children=0, other_passengers=0, customer_number, system, token)
    funding_xml = Nokogiri::XML(funding_options.body)
    Rails.logger.info("Begin Funding info")
    Rails.logger.info(funding_xml)
    Rails.logger.info("End Funding info")
    order =  build_order(sponsors, trip_purpose_raw, is_depart, scheduled_time, from_trip_place, to_trip_place, note_to_driver="", assistant=false, companions=0, children=0, other_passengers=0, customer_number, system, token, funding_xml, funding_array)
    order = Nokogiri::XML(order)
    order.children.first.set_attribute('version', '2')
    order = order.to_s
    resp = send_request(url, token, 'POST', order)

    begin
      resp_code = resp.code
    rescue
      return false, "500"
    end

    if resp_code != "200"
      Honeybadger.notify(
          :error_class   => "Unable to query fare",
          :error_message => "Service failure: fixed: resp.code not 200, #{resp.message}",
          :parameters    => {resp_code: resp_code, resp: resp}
      )
      return false, {'id'=>resp_code.to_i, 'msg'=>resp.message}
    end
    fare = unpack_fare_response(resp)
    return true, fare
  end

  def query_guest_fare(itinerary)

    url_options =  "/api/order/" + itinerary.service.booking_system_id + "/queryfare"
    url = BASE_URL + url_options

    #First: Find Gen Public Fare
    service = itinerary.service
    funding_source = service.funding_sources.where(general_public: true).first
    guest_id = service.fare_user

    order = build_discount_order(itinerary, funding_source.code, guest_id)
    order = Nokogiri::XML(order)
    order.children.first.set_attribute('version', '2')
    order = order.to_s
    resp = send_request(url, itinerary.service.booking_token, 'POST', order)

    begin
      resp_code = resp.code
    rescue
      return false, "500"
    end

    if resp_code != "200"
      Honeybadger.notify(
          :error_class   => "Unable to query fare",
          :error_message => "Service failure: fixed: resp.code not 200, #{resp.message}",
          :parameters    => {resp_code: resp_code, resp: resp}
      )
      return false, {'id'=>resp_code.to_i, 'msg'=>resp.message}
    end
    fare = unpack_fare_response(resp)

    return true, fare

  end

  def build_discount_array(itinerary)
    url_options =  "/api/order/" + itinerary.service.booking_system_id + "/queryfare"
    url = BASE_URL + url_options

    #First: Find Gen Public Fare
    service = itinerary.service
    funding_sources = service.funding_sources
    guest_id = service.fare_user
    discount_array = []
    Rails.logger.info "Number of funding sources to try: " + funding_sources.count.to_s

    funding_sources.each do |funding_source|
      Rails.logger.info(funding_source.code)

      order = build_discount_order(itinerary, funding_source.code, guest_id)
      order = Nokogiri::XML(order)
      order.children.first.set_attribute('version', '2')
      order = order.to_s
      resp = send_request(url, itinerary.service.booking_token, 'POST', order)

      begin
        resp_code = resp.code
      rescue
        resp_code = nil
      end

      if resp_code == "200"
        fare = unpack_fare_response(resp)
        discount_array.append({fare: fare, comment: funding_source.comment, funding_source: funding_source.code, base_fare: funding_source.general_public})
      end
    end

    discount_array

  end


  def unpack_fare_response (resp)
    resp_xml = Nokogiri::XML(resp.body)
    Rails.logger.info(resp_xml)
    client_copay = resp_xml.xpath("fare").xpath("client_copay").text
    return client_copay.to_f/100.0
  end


  ## GET Operations
  def get_trip_purposes_from_itinerary(itinerary)
    get_trip_purposes(get_customer_id(cu), itinerary.service.booking_system_id, itinerary.service.booking_token, itinerary.service.disallowed_purposes_array)
  end

  def get_trip_purposes_from_traveler(traveler)
    user_service = UserService.where(user_profile: traveler.user_profile).order('created_at').last
    get_trip_purposes(get_ecolane_customer_id(user_service.external_user_id, user_service.service.booking_system_id, user_service.service.booking_token), user_service.service.booking_system_id, user_service.service.booking_token, user_service.service.disallowed_purposes_array)
  end

  def get_trip_purposes_from_customer_number(customer_number, system_id, token)
    get_trip_purposes(get_ecolane_customer_id(customer_number, system_id, token), system_id, token, Service.find_by(booking_system_id: system_id).disallowed_purposes_array)
  end

  def get_trip_purposes(customer_id, system_id, token, disallowed_purposes)
    purposes = []
    customer_information = fetch_customer_information(customer_id, system_id, token, funding = true)
    resp_xml = Nokogiri::XML(customer_information)
    resp_xml.xpath("customer").xpath("funding").xpath("funding_source").each do |funding_source|
      funding_source.xpath("allowed").each do |allowed|
        purpose = allowed.xpath("purpose").text
        unless purpose.in? purposes or purpose.downcase.strip.in? disallowed_purposes
          purposes.append(purpose)
        end
      end

    end

    purposes.sort

  end

  #OK
  def verify_client_id(customer_number, dob, system, token)
    search_for_customers([['customer_number', customer_number], ['date_of_birth', dob]], system, token)
  end

  def fetch_customer_information(customer_id, system_id, token, funding=false, locations=false)
    url_options = "/api/customer/" + system_id.to_s + '/'
    url_options += customer_id.to_s
    url_options += "?funding=" + funding.to_s + "&locations=" + locations.to_s

    url = BASE_URL + url_options
    Rails.logger.debug URI.parse(url)
    t = Time.now

    resp = send_request(url, token )

    if resp.code != "200"
      Honeybadger.notify(
          :error_class   => "Service failure",
          :error_message => "Service failure: fixed: resp.code not 200, #{resp.message}",
          :parameters    => {resp_code: resp.code, resp: resp}
      )
      return false, {'id'=>resp.code.to_i, 'msg'=>resp.message}
    end
    resp.body
  end

  #OK
  def search_for_customers(terms = {}, system, token)


    url_options = "/api/customer/" + system.to_s + '/search?'
    terms.each do |term|
      url_options += "&" + term[0].to_s + '=' + term[1].to_s
    end
    url = Oneclick::Application.config.ecolane_base_url + url_options
    resp = send_request(url, token)
  end



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

  def validate_passenger(customer_number, dob, system_id, token)

    iso_dob = iso8601ify(dob)
    if iso_dob.nil?
      return false, "", ""
    end
    resp = search_for_customers({"customer_number" => customer_number, "date_of_birth" => iso_dob.to_s}, system_id, token)
    resp = unpack_validation_response(resp)
    return resp[0], resp[2][0], resp[2][1]
  end

  def get_ecolane_traveler(external_user_id, dob, county, first_name, last_name)

    service = Service.find_by(external_id: county_to_external_id(county).downcase.strip)
    user_service = UserService.where(external_user_id: external_user_id, service: service).order('created_at').last
    if user_service
      u = user_service.user_profile.user

    else
      new_user = true
      u = User.where(email: external_user_id.gsub(" ","_") + '_' + service.booking_system_id.to_s + '@ecolane_user.com').first_or_create
      u.first_name = first_name
      u.last_name = last_name
      u.password = dob
      u.password_confirmation = dob
      u.roles << Role.where(name: "registered_traveler").first
      up = UserProfile.new
      up.user = u
      up.save!
      result = u.save
    end

    #Update Birth Year
    dob_object = Characteristic.where(code: "date_of_birth").first
    if dob_object
      user_characteristic = UserCharacteristic.where(characteristic_id: dob_object.id, user_profile: u.user_profile).first_or_initialize
      user_characteristic.value = dob.split('/')[2]
      user_characteristic.save
    end

    if new_user #Create User Service
      user_service = UserService.where(user_profile_id: u.user_profile.id, service_id: service.id).first_or_initialize
      user_service.external_user_id = external_user_id
      user_service.save
    end
    u
  end

  def fetch_customer_orders(customer_id, system_id, token)
    url_options = "/api/customer/" + system_id + '/'
    url_options += customer_id.to_s
    url_options += "/orders"
    url = BASE_URL + url_options
    send_request(url, token)
  end

  def fetch_single_order(trip_id, system_id, token)
    url_options = "/api/order/" + system_id + '/'
    url_options += trip_id.to_s
    url = BASE_URL + url_options
    send_request(url, token)
  end



  ## Building hash objects that become XML nodes
  def build_order(sponsors, trip_purpose_raw, is_depart, scheduled_time, from_trip_place, to_trip_place, note_to_driver, assistant, companions, children, other_passengers, customer_number, system, token, funding_xml=nil, funding_array=nil)

    #If we have already built an order for this itinerary, return it
    #if itinerary.order_xml?
    #  return itinerary.order_xml
    #end

    order_hash = build_order_hash(sponsors, trip_purpose_raw, is_depart, scheduled_time, from_trip_place, to_trip_place, note_to_driver, assistant, companions, children, other_passengers, customer_number, system, token, funding_xml, funding_array)
    order_xml = order_hash.to_xml(root: 'order', :dasherize => false)

    order_xml

  end

  def build_order_hash(sponsors, trip_purpose_raw, is_depart, scheduled_time, from_trip_place, to_trip_place, note_to_driver, assistant, companions, children, other_passengers, customer_number, system, token, funding_xml=nil, funding_array=nil)
    order = {customer_id: get_customer_id(customer_number, system, token), assistant: yes_or_no(assistant), companions: companions, children: children, other_passengers: other_passengers, pickup: build_pu_hash(is_depart, scheduled_time, from_trip_place, note_to_driver), dropoff: build_do_hash(is_depart, scheduled_time, to_trip_place)}

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

  ############################################################
  #Find Fares for users that do not have accounts with ecolane
  ############################################################
  def build_discount_order(itinerary, funding_source, guest_id)
    order_hash = build_discount_order_hash(itinerary, funding_source, guest_id)
    order_xml = order_hash.to_xml(root: 'order', :dasherize => false)
    order_xml
  end

  def build_discount_order_hash(itinerary, funding_source, guest_id)
    order = {customer_id: get_ecolane_customer_id(guest_id, itinerary.service.booking_system_id, itinerary.service.booking_token), assistant: yes_or_no(itinerary.assistant || false), companions: itinerary.companions || 0, children: itinerary.children || 0, other_passengers: itinerary.other_passengers || 0, pickup: build_pu_hash(itinerary), dropoff: build_do_hash(itinerary)}
    order[:funding] = build_funding_hash_from_funding_source(itinerary, funding_source, Nokogiri::XML(query_funding_options(sponsors, trip_purpose_raw, is_depart, scheduled_time, from_trip_place, to_trip_place, note_to_driver, assistant, companions, children, other_passengers, customer_number, system, token).body))
    order
  end

  def build_discount_funding_hash(itinerary, funding_source)
    #TODO: This purpose has to be updated when trip purposes are pulled in on-the-fly
    return {funding_source: funding_source, purpose: itinerary.trip_part.trip.trip_purpose_raw}
  end
  ############################################################


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
      do_hash = {location: to_trip_place}
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
      Honeybadger.notify(
          :error_class   => "Service failure",
          :error_message => "Service failure: fixed: #{e.message}",
          :parameters    => {url: url}
      )
      Rails.logger.info("Sending Error")
      return false, {'id'=>500, 'msg'=>e.to_s}
    end
  end

  def cancel(confirmation_number, system, token)
    url_options = "/api/order/" + system + '/'
    url_options += confirmation_number.to_s

    url =  Oneclick::Application.config.ecolane_base_url + url_options

    resp = send_request(url, token, 'DELETE')

    begin
      resp_code = resp.code
    rescue
      return false
    end

    if resp_code == "200"
      Rails.logger.debug "Trip " + confirmation_number.to_s + " canceled."
      #The trip was successfully canceled
      return true
    elsif get_trip_status(confirmation_number, system, token) == 'canceled'
      Rails.logger.debug "Trip " + confirmation_number.to_s + " already canceled."

      #The trip was not successfully deleted, because it was already canceled
      return true
    else
      Rails.logger.debug "Trip " + confirmation_number.to_s + " cannot be canceled."
      #The trip is not canceled
      return false
    end

  end


  ## Utility functions:
  #Ecolane has two unique identifiers customer_number and customer_id.


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

  def county_to_service(county)
    Service.find_by(external_id: county_to_external_id(county).downcase.strip)
  end

  def county_to_external_id(county)
    mapping = Oneclick::Application.config.ecolane_county_mapping[county.downcase.strip.to_s]
    return mapping.nil? ? county : mapping
  end

  def yes_or_no value
    value.to_bool ? true : false
  end

end