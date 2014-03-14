require 'json'
require 'net/http'
require 'OpenSSL'

class EcolaneHelpers

  MAX_REQUEST_TIMEOUT = Rails.application.config.remote_request_timeout_seconds
  MAX_READ_TIMEOUT    = Rails.application.config.remote_read_timeout_seconds

  #todo: Make configurable
  SYSTEM_ID = "ococtest"
  X_ECOLANE_TOKEN = "RIOEDkA3kBaIvpOHK9w2"
  BASE_URL = "https://rabbit-test.ecolane.com"

  def fetch_customer_information(customer_id, funding=false, locations=false)

    url_options = "/api/customer/" + SYSTEM_ID + '/'
    url_options += customer_id.to_s
    url_options += "?funding=" + funding.to_s + "&locations=" + locations.to_s

    url = BASE_URL + url_options
    p url
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

    data = resp.body
    #doc = Nokogiri::XML(data)
    return data

  end

  def search_for_customers(terms = {}, type = 'exact')

    url_options = "/api/customer/" + SYSTEM_ID + '/search?type='
    url_options += type
    terms.each do |term|
      url_options += '&' + term[0].to_s + '=' + term[1].to_s
    end
    url = BASE_URL + url_options
    p url
    resp = send_request(url)

  end

  def check_customer_validity(customer_id, service=nil)
    url_options = "/api/customer/" + SYSTEM_ID + '/'
    url_options += customer_id.to_s
    url_options += "/validity"
    unless service.nil?
      url_options += "?service=" + service.to_s
    end

    url = BASE_URL + url_options
    resp = send_request(url)
  end

  def fetch_customer_orders(customer_id)
    url_options = "/api/customer/" + SYSTEM_ID + '/'
    url_options += customer_id.to_s
    url_options += "/orders"
    url = BASE_URL + url_options
    p url
    send_request(url)
  end

  def query_funding_options(customer_id)
    url_options = "/api/order/" + SYSTEM_ID + '/queryfunding'
    url = BASE_URL + url_options
    order =  build_order
    #order = fetch_customer_orders(76331)
    p order
    p url
    order = Nokogiri::XML(order)
    order.children.first.set_attribute('version', '2')
    order = order.to_s
    puts order
    send_request(url, 'POST', order)

  end


  def build_order
    order_hash = build_order_hash
    order_hash.to_xml(root: 'order', :dasherize => false)
  end

  def build_order_hash
    {customer_id: 76331, assistant: false, companions: 0, children: 0, other_passengers: 0, pickup: build_pu_hash, dropoff: build_do_hash}

  end

  def build_pu_hash
    pu_do_hash = {requested: (Time.now + 7200).xmlschema.chop.chop.chop.chop.chop.chop, location: build_location_hash}

  end

  def build_do_hash #temp funciton
    pu_do_hash = {requested: (Time.now + 14400).xmlschema.chop.chop.chop.chop.chop.chop, location: build_location_hash}

  end


  def build_location_hash
    location_hash = {name: 'Test Location', latitude: 39.970806, longitude: -76.742463}
  end

  def get_location_element
    builder = Nokogiri::XML::Builder.new do |xml|
        xml.latitude {39.963964}
        xml.longitude {-76.690171}
    end
    builder.xml
  end

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
      p 'failure'
      return false, {'id'=>500, 'msg'=>e.to_s}
    end
  end

end