require 'net/http'
require 'openssl'

class RidepilotServices

  def authenticate_customer(endpoint, token, provider_id, customer_id, customer_token)

    url = endpoint + "/authenticate_customer?provider_id=" + provider_id.to_s + "&customer_id=" + customer_id.to_s  + "&customer_token=" + customer_token.to_s
    response = send_request(url, token, 'GET')

    if response and response.code == '200'
      return true, ""
    elsif response
      body = JSON.parse(response.body)
      return false, body["error"]
    else
      return false, ""
    end

  end

  def trip_purposes(endpoint, token, provider_id)
    url = endpoint + "/trip_purposes?provider_id=" + provider_id.to_s
    response = send_request(url, token, 'GET')

    if response and response.code == '200'
      body = JSON.parse(response.body)
      return true, body["trip_purposes"]
    elsif response
      body = JSON.parse(response.body)
      return false, body["error"]
    else
      return false, ""
    end
  end

  def cancel_trip(endpoint, token, customer_id, customer_token, trip_id)
    url = endpoint + "/cancel"
    message = {customer_id: customer_id, customer_token: customer_token, trip_id: trip_id}
    response = send_request(url, token, type="DELETE", message: message)

    if response and response.code == '200'
      return true, ""
    elsif response
      body = JSON.parse(response.body)
      return false, body["error"]
    else
      return false, ""
    end

  end

  def send_request(url, token, type='GET', message=nil, use_ssl=true)

    Rails.logger.info("Sending Request . . .")
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

      req.add_field 'X-RIDEPILOT-TOKEN', token
      req.add_field 'Content-Type', 'application/json'

      http = Net::HTTP.new(uri.host, uri.port)

      http.use_ssl = use_ssl
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      resp = http.start {|http| http.request(req)}
      return resp

    rescue Exception=>e
      Rails.logger.info("Sending Error")
      return nil
    end
  end

end