require 'net/http'
require 'OpenSSL'
require 'Indirizzo'

class EcolaneHelpers

  SYSTEM_ID = Oneclick::Application.config.ecolane_system_id
  X_ECOLANE_TOKEN = Oneclick::Application.config.ecolane_x_ecolane_token
  BASE_URL = Oneclick::Application.config.ecolane_base_url


  ## Post/Put Operations
  def book_itinerary(itinerary)
    funding_options = query_funding_options(itinerary)
    funding_xml = Nokogiri::XML(funding_options.body)
    request_booking(itinerary, funding_xml)
  end

  def request_booking(itinerary, funding_xml)
    url_options = "/api/order/" + SYSTEM_ID + "?overlaps=reject"
    url = BASE_URL + url_options
    order =  build_order(itinerary, funding_xml)
    order = Nokogiri::XML(order)
    order.children.first.set_attribute('version', '2')
    order = order.to_s
    send_request(url, 'POST', order)
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


  ## GET Operations
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

  def search_for_customers(terms = {}, type = 'exact')
    url_options = "/api/customer/" + SYSTEM_ID + '/search?type='
    url_options += type
    terms.each do |term|
      url_options += '&' + term[0].to_s + '=' + term[1].to_s
    end
    url = BASE_URL + url_options
    send_request(url)
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


  ## Building hash objects that become XML nodes
  def build_order(itinerary, funding_xml=nil)
    order_hash = build_order_hash(itinerary, funding_xml)
    order_hash.to_xml(root: 'order', :dasherize => false)
  end

  def build_order_hash(itinerary, funding_xml=nil)
    #TODO: Pull Passengers from itinerary
    order = {customer_id: get_customer_id(itinerary), assistant: false, companions: 0, children: 0, other_passengers: 0, pickup: build_pu_hash(itinerary), dropoff: build_do_hash(itinerary)}
    if funding_xml
      order[:funding] = build_funding_hash(itinerary, funding_xml)
    end
    order
  end

  def build_funding_hash(itinerary, funding_xml)
    purpose = itinerary.trip_part.trip.trip_purpose.code
    #TODO: Pickup here by matching the tripPurpose
    funding_source  =  funding_xml.xpath("funding_options").xpath("option").first.xpath("funding_source").text
    purpose  = funding_xml.xpath("funding_options").xpath("option").first.xpath("purpose").text
    {funding_source: funding_source, purpose: purpose}
  end

  def build_pu_hash(itinerary)
    if itinerary.trip_part.is_depart
      pu_hash = {requested: (itinerary.trip_part.scheduled_time).xmlschema.chop.chop.chop.chop.chop.chop, location: build_location_hash(itinerary.trip_part.from_trip_place)}
    else
      pu_hash = {location: build_location_hash(itinerary.trip_part.from_trip_place)}
    end
    pu_hash
  end

  def build_do_hash(itinerary) #temp funciton
    if itinerary.trip_part.is_depart
      do_hash = {location: build_location_hash(itinerary.trip_part.to_trip_place)}
    else
      do_hash = {requested: (itinerary.trip_part.scheduled_time).xmlschema.chop.chop.chop.chop.chop.chop, location: build_location_hash(itinerary.trip_part.to_trip_place)}
    end
    do_hash
  end

  def build_location_hash(place)
    parsable_address = Indirizzo::Address.new(place.address1)
    {street_number: parsable_address.number, street:parsable_address.street.first, city: place.city, state: place.state, zip: place.zip}
  end


  ## Send the Requests
  def send_request(url, type='GET', message=nil)
    begin
      uri = URI.parse(url)

      case type.downcase
        when 'post'
          req = Net::HTTP::Post.new(uri.path)
          req.body = message
        else
          req = Net::HTTP::Get.new(uri.path)
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
  def get_customer_id(itinerary)
    itinerary.trip_part.trip.user.user_profile.user_services.where(service: itinerary.service).first.external_user_id
  end


  ### Testing functions:
  def test_build_location_hash(place)
    {street_number: 434, street:"W Princess St", city: "York", state: 'PA'}
  end

  def test_build_location2_hash(place)
    {street_number: 514, street:"S Pershing Ave", city: "York", state: 'PA'}
  end

end