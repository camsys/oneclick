require 'net/http'
require 'openssl'
require 'indirizzo'

class EcolaneHelpers

  begin
    SYSTEM_ID = Oneclick::Application.config.ecolane_system_id
    X_ECOLANE_TOKEN = Oneclick::Application.config.ecolane_x_ecolane_token
    BASE_URL = Oneclick::Application.config.ecolane_base_url
  rescue NoMethodError
    SYSTEM_ID = nil
    X_ECOLANE_TOKEN = nil
    BASE_URL = nil
  end

  def get_ecolane_customer_id(customer_number)
    resp = search_for_customers(terms = {customer_number: customer_number})
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
  def book_itinerary(itinerary)
    begin
      funding_options = query_funding_options(itinerary)
      funding_xml = Nokogiri::XML(funding_options.body)
      Rails.logger.info(funding_xml)
    rescue
      Rails.logger.debug "Booking error #003"
      return false, "Booking error."
    end

    resp = request_booking(itinerary, funding_xml)

    return unpack_booking_response(resp, itinerary)
  end

  def unpack_booking_response(resp, itinerary)
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
          itinerary.booking_confirmation = confirmation
          itinerary.save
        rescue
          Rails.logger.debug "Booking error #002"
          return false, "Unknown response #002"
        end

        return true, messages
    end

    return false, "Unknown response."
  end

  def get_trip_info(itinerary)
    resp = fetch_single_order(itinerary.booking_confirmation)
    return unpack_fetch_single(resp, itinerary.booking_confirmation)

  end

  def get_trip_status(trip_id)
    resp = fetch_single_order(trip_id)
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

  def request_booking(itinerary, funding_xml)
    url_options = "/api/order/" + SYSTEM_ID + "?overlaps=reject"
    url = BASE_URL + url_options
    order =  build_order(itinerary, funding_xml)
    order = Nokogiri::XML(order)
    order.children.first.set_attribute('version', '2')
    order = order.to_s
    result  = send_request(url, 'POST', order)
    Rails.logger.info('Order Request Sent to Ecolane:')
    Rails.logger.info(order)
    result
  end

  def query_funding_options(itinerary)
    url_options = "/api/order/" + SYSTEM_ID + '/queryfunding'
    url = BASE_URL + url_options
    order =  build_order(itinerary)
    order = Nokogiri::XML(order)
    order.children.first.set_attribute('version', '2')
    order = order.to_s
    send_request(url, 'POST', order)
  end

  def query_fare(itinerary)

    url_options =  "/api/order/" + SYSTEM_ID + "/queryfare"
    url = BASE_URL + url_options
    funding_options = query_funding_options(itinerary)
    funding_xml = Nokogiri::XML(funding_options.body)
    Rails.logger.info(funding_xml)
    order =  build_order(itinerary, funding_xml)
    order = Nokogiri::XML(order)
    order.children.first.set_attribute('version', '2')
    order = order.to_s
    resp = send_request(url, 'POST', order)

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
    fare = unpack_fare_response(resp, itinerary)
    return true, fare
  end

  def unpack_fare_response (resp, itinerary)
    resp_xml = Nokogiri::XML(resp.body)
    Rails.logger.info(resp_xml)
    client_copay = resp_xml.xpath("fare").xpath("client_copay").text
    return client_copay.to_f/100.0
  end


  ## GET Operations
  def verify_client_id(client_id, dob)
    search_for_customers([['customer_number', client_id], ['date_of_birth', dob]])
  end

  def fetch_customer_information(customer_id, funding=false, locations=false)
    url_options = "/api/customer/" + SYSTEM_ID + '/'
    url_options += customer_id.to_s
    url_options += "?funding=" + funding.to_s + "&locations=" + locations.to_s

    url = BASE_URL + url_options
    Rails.logger.debug URI.parse(url)
    t = Time.now

    resp = send_request(url )

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

  def search_for_customers(terms = {})
    url_options = "/api/customer/" + SYSTEM_ID + '/search?'
    terms.each do |term|
      url_options += "&" + term[0].to_s + '=' + term[1].to_s
    end
    url = BASE_URL + url_options
    resp = send_request(url)
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

  def validate_passenger(customer_number, dob)

    return true, 'George', 'Burdell'

    iso_dob = iso8601ify(dob)
    if iso_dob.nil?
      return false, "", ""
    end
    resp = search_for_customers({"customer_number" => customer_number, "date_of_birth" => iso_dob.to_s})
    resp = unpack_validation_response(resp)
    return resp[0], resp[2][0], resp[2][1]
  end

  def get_ecolane_traveler(external_user_id, dob, first_name, last_name)

    user_service = UserService.where(external_user_id: external_user_id).order('created_at').last
    if user_service
      u = user_service.user_profile.user
    else
      new_user = true
      u = User.where(email: external_user_id + '@ecolane_user.com').first_or_create
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
      Service.where(booking_service_code: 'ecolane').each do |booking_service|
        user_service = UserService.where(user_profile: u.user_profile, service: booking_service).first_or_initialize
        user_service.external_user_id = external_user_id
        user_service.save
      end
    end
    u
  end

  def check_customer_validity(customer_id, service=nil)
    url_options = "/api/customer/" + SYSTEM_ID + '/'
    url_options += customer_id.to_s
    url_options += "/validity"
    unless service.nil?
      url_options += "?service=" + service.to_s
    end

    url = BASE_URL + url_options
    send_request(url)
  end

  def fetch_customer_orders(customer_id)
    url_options = "/api/customer/" + SYSTEM_ID + '/'
    url_options += customer_id.to_s
    url_options += "/orders"
    url = BASE_URL + url_options
    send_request(url)
  end

  def fetch_single_order(trip_id)
    url_options = "/api/order/" + SYSTEM_ID + '/'
    url_options += trip_id.to_s
    url = BASE_URL + url_options
    send_request(url)
  end

  ## Building hash objects that become XML nodes
  def build_order(itinerary, funding_xml=nil)

    #If we have already built an order for this itinerary, return it
    #if itinerary.order_xml?
    #  return itinerary.order_xml
    #end

    order_hash = build_order_hash(itinerary, funding_xml)
    order_xml = order_hash.to_xml(root: 'order', :dasherize => false)

    #If this is an order that includes funding information, save it and re-use it instead of building a new order
    if funding_xml
      itinerary.order_xml = order_xml
      itinerary.save
    end

    order_xml

  end

  def build_order_hash(itinerary, funding_xml=nil)

    #TODO: Pull Passengers from itinerary
    order = {customer_id: get_customer_id(itinerary), assistant: itinerary.assistant || false, companions: itinerary.companions || 0, children: itinerary.children || 0, other_passengers: itinerary.other_passengers || 0, pickup: build_pu_hash(itinerary), dropoff: build_do_hash(itinerary)}

    if funding_xml
      order[:funding] = build_funding_hash(itinerary, funding_xml)
    end
    Rails.logger.info(order)
    order
  end

  def build_funding_hash(itinerary, funding_xml)

    #Get the default funding source for this customer and build an array of valid funding source ordered from
    # most desired to least desired.
    default_funding = get_default_funding_source(get_customer_id(itinerary))
    funding_array = [default_funding] + Oneclick::Application.config.funding_source_order

    purpose = itinerary.trip_part.trip.trip_purpose.code
    min_index = 10000
    best_funding_source = nil
    best_sponsor = nil
    best_purpose = nil

    #Cycle through all the funding sources for this trip.  Return the one with the lowest index.
    funding_xml.xpath("funding_options").xpath("option").each do |options|

      ecolane_purpose = options.xpath("purpose").text
      simplified_ecolane_purpose = ecolane_purpose.downcase.gsub(%r{[ /]}, '_')

      if simplified_ecolane_purpose == 'other' or simplified_ecolane_purpose == purpose
        funding_source = options.xpath("funding_source").text
        index = funding_array.index(funding_source)

        if index and (index < min_index or (index == min_index and best_sponsor.nil?))
          min_index = index
          best_funding_source = funding_source
          best_sponsor = options.xpath("sponsor").text
          best_purpose = ecolane_purpose

          #If we match the default funding source with a sponsor, go ahead and return.
          if min_index == 0 and not best_sponsor.nil?
            return {funding_source: best_funding_source, purpose: best_purpose , sponsor: best_sponsor}
          end

        end

      end
    end

    return {funding_source: best_funding_source, purpose: best_purpose , sponsor: best_sponsor}

  end


  #Find the default funding source for a customer id
  # (customer_id is the internal id and not the client id)
  def get_default_funding_source(customer_id)

    customer_information = fetch_customer_information(customer_id, funding = true)
    resp_xml = Nokogiri::XML(customer_information)
    resp_xml.xpath("customer").xpath("funding").xpath("funding_source").each do |funding_source|
      if funding_source.attribute("default") and funding_source.attribute("default").value.downcase == "yes"
        return funding_source.xpath("name").text
      end
    end

    nil

  end

  #Build the hash for the pickup request
  def build_pu_hash(itinerary)
    if itinerary.trip_part.is_depart
      pu_hash = {requested: (itinerary.trip_part.scheduled_time).xmlschema.chop.chop.chop.chop.chop.chop, location: build_location_hash(itinerary.trip_part.from_trip_place)}
    else
      pu_hash = {location: build_location_hash(itinerary.trip_part.from_trip_place)}
    end
    pu_hash
  end

  #Build the hash for the drop off request
  def build_do_hash(itinerary) #temp funciton
    if itinerary.trip_part.is_depart
      do_hash = {location: build_location_hash(itinerary.trip_part.to_trip_place)}
    else
      do_hash = {requested: (itinerary.trip_part.scheduled_time).xmlschema.chop.chop.chop.chop.chop.chop, location: build_location_hash(itinerary.trip_part.to_trip_place)}
    end
    do_hash
  end

  #Build a location hash (Used for dropoffs and pickups )
  def build_location_hash(place)
    street_number, street = if place.address1.present?
      parsable_address = Indirizzo::Address.new(place.address1)
      [parsable_address.number, parsable_address.street.first]
    end

    {street_number: street_number, street: street, city: place.city, state: place.state, zip: place.zip}
  end


  ## Send the Requests
  def send_request(url, type='GET', message=nil)


    url.sub! " ", "%20"

    Rails.logger.info(url)

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

      req.add_field 'X-ECOLANE-TOKEN', X_ECOLANE_TOKEN
      req.add_field 'Content-Type', 'text/xml'

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      resp = http.start {|http| http.request(req)}
      Rails.logger.info(resp.inspect)
      return resp
    rescue Exception=>e
      Honeybadger.notify(
          :error_class   => "Service failure",
          :error_message => "Service failure: fixed: #{e.message}",
          :parameters    => {url: url}
      )
      return false, {'id'=>500, 'msg'=>e.to_s}
    end
  end


  ## Utility functions:
  #Ecolane has two unique identifiers customer_number and customer_id.

  def unpack_funding_source(order_xml)
    true
  end

  def get_customer_id(itinerary)
    user_service = itinerary.trip_part.trip.user.user_profile.user_services.where(service: itinerary.service).first
    if (Time.now - user_service.updated_at > 300) or user_service.customer_id.nil?
      user_service.customer_id = get_ecolane_customer_id(user_service.external_user_id)
      user_service.save
    end
    return user_service.customer_id
  end

  def cancel_itinerary(itinerary)
    result = cancel(itinerary.booking_confirmation)
    if result
      itinerary.booking_confirmation = nil
      itinerary.save
    end
    result
  end

  def cancel(trip_conf)
    url_options = "/api/order/" + SYSTEM_ID + '/'
    url_options += trip_conf.to_s

    url = BASE_URL + url_options

    resp = send_request(url, 'DELETE')
    begin
      resp_code = resp.code
    rescue
      return false
    end
    if resp_code == "200"
      Rails.logger.debug "Trip " + trip_conf.to_s + " canceled."
      #The trip was successfully canceled
      return true
    elsif get_trip_status(trip_conf) == 'canceled'
      Rails.logger.debug "Trip " + trip_conf.to_s + " already canceled."

      #The trip was not successfully deleted, because it was already canceled
      return true
    else
      Rails.logger.debug "Trip " + trip_conf.to_s + " cannot be canceled."
      #The trip is not canceled
      return false
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


  ### Testing functions:
  def test_build_location_hash(place)
    {street_number: 434, street:"W Princess St", city: "York", state: 'PA'}
  end

  def test2_build_location_hash(place)
    {street_number: 514, street:"S Pershing Ave", city: "York", state: 'PA'}
  end

end