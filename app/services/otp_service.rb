class OTPService

def self.get_fixed_itineraries(from, to, trip_datetime, arriveBy, mode="TRANSIT,WALK", wheelchair="false", walk_speed=3.0, max_walk_distance=2, try_count=Oneclick::Application.config.OTP_retry_count)
    try = 1
    result = nil
    response = nil

    while try <= try_count
      result, response = get_fixed_itineraries_once(from, to, trip_datetime, arriveBy, mode, wheelchair, walk_speed, max_walk_distance)
      if result
        break
      else
        Rails.logger.info [from, to, trip_datetime, arriveBy, mode, wheelchair, walk_speed, max_walk_distance]
        Rails.logger.info response
        Rails.logger.info "Try " + try.to_s + " failed."
        Rails.logger.info "Trying again..."

      end
      sleep([try,3].min) #The first time wait 1 second, the second time wait 2 seconds, wait 3 seconds every time after that.
      try +=1
    end

    return result, response

  end

  def self.get_fixed_itineraries_once(from, to, trip_datetime, arriveBy, mode="TRANSIT,WALK", wheelchair="false", walk_speed=3.0, max_walk_distance=2)
    #walk_speed is defined in MPH and converted to m/s before going to OTP
    #max_walk_distance is defined in miles and converted to meters before going to OTP

    #Parameters
    time = trip_datetime.strftime("%-I:%M%p")
    date = trip_datetime.strftime("%Y-%m-%d")
    base_url = Oneclick::Application.config.open_trip_planner
    url_options = "&time=" + time
    url_options += "&mode=" + mode + "&date=" + date
    url_options += "&toPlace=" + to[0].to_s + ',' + to[1].to_s + "&fromPlace=" + from[0].to_s + ',' + from[1].to_s
    url_options += "&wheelchair=" + wheelchair
    url_options += "&arriveBy=" + arriveBy.to_s
    url_options += "&walkSpeed=" + (0.44704*walk_speed).to_s
    url_options += "&maxWalkDistance=" + (1609.34*max_walk_distance).to_s

    url = base_url + url_options
    Rails.logger.info URI.parse(url)
    t = Time.now
    begin
      resp = Net::HTTP.get_response(URI.parse(url))
      Rails.logger.info(resp.ai)
    rescue Exception=>e
      Honeybadger.notify(
        :error_class   => "Service failure",
        :error_message => "Service failure: fixed: #{e.message}",
        :parameters    => {url: url}
      )
      return false, {'id'=>500, 'msg'=>e.to_s}
    end

    if resp.code != "200"
      Honeybadger.notify(
        :error_class   => "Service failure",
        :error_message => "Service failure: fixed: resp.code not 200, #{resp.message}",
        :parameters    => {resp_code: resp.code, resp: resp}
      )
      return false, {'id'=>resp.code.to_i, 'msg'=>resp.message}
    end

    data = resp.body
    result = JSON.parse(data)
    if result.has_key? 'error' and not result['error'].nil?
      Honeybadger.notify(
        :error_class   => "Service failure",
        :error_message => "Service failure: fixed: result has error: #{result['error']}",
        :parameters    => {result: result}
      )
      return false, result['error']
    else
      return true, result['plan']
    end

  end

end