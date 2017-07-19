require 'json'
require 'net/http'
require 'mechanize'

class TripPlanner

  MAX_REQUEST_TIMEOUT = Rails.application.config.remote_request_timeout_seconds
  MAX_READ_TIMEOUT    = Rails.application.config.remote_read_timeout_seconds
  METERS_TO_MILES = 0.000621371192

  include ServiceAdapters::RideshareAdapter

  def get_fixed_itineraries(from, to, trip_datetime, arriveBy, mode="TRANSIT,WALK", wheelchair="false", walk_speed=3.0, max_walk_distance=2, max_bicycle_distance=5, optimize='QUICK', num_itineraries = 3, try_count=Oneclick::Application.config.OTP_retry_count)
    try = 1
    result = nil
    response = nil

    while try <= try_count
      result, response = get_fixed_itineraries_once(from, to, trip_datetime, arriveBy, mode, wheelchair, walk_speed, max_walk_distance, max_bicycle_distance, optimize, num_itineraries)
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

  def get_fixed_itineraries_once(from, to, trip_datetime, arriveBy, mode="TRANSIT,WALK", wheelchair="false", walk_speed=3.0, max_walk_distance=2, max_bicycle_distance=5, optimize='QUICK', num_itineraries=3)
    #walk_speed is defined in MPH and converted to m/s before going to OTP
    #max_walk_distance is defined in miles and converted to meters before going to OTP

    #Parameters
    time = trip_datetime.strftime("%-I:%M%p")
    date = trip_datetime.strftime("%Y-%m-%d")
    base_url = Oneclick::Application.config.open_trip_planner + "/plan?"
    url_options = "&time=" + time
    url_options += "&mode=" + mode + "&date=" + date
    url_options += "&toPlace=" + to[0].to_s + ',' + to[1].to_s + "&fromPlace=" + from[0].to_s + ',' + from[1].to_s
    url_options += "&wheelchair=" + wheelchair
    url_options += "&arriveBy=" + arriveBy.to_s
    url_options += "&walkSpeed=" + (0.44704*walk_speed).to_s

    #If it's a bicycle trip, OTP uses walk distance as the bicycle distance
    if mode == "TRANSIT,BICYCLE" or mode == "BICYCLE"
      url_options += "&maxWalkDistance=" + (1609.34*max_bicycle_distance).to_s
    else
      url_options += "&maxWalkDistance=" + (1609.34*max_walk_distance).to_s
    end

    url_options += "&numItineraries=" + num_itineraries.to_s

    #Unless the optimiziton = QUICK (which is the default), set additional parameters
    case optimize.downcase
      when 'walking'
        url_options += "&walkReluctance=" + Oneclick::Application.config.otp_walk_reluctance.to_s
      when 'transfers'
        url_options += "&transferPenalty=" + Oneclick::Application.config.otp_transfer_penalty.to_s
    end

    url = base_url + url_options

    Rails.logger.info URI.parse(url)
    t = Time.now
    begin
      resp = Net::HTTP.get_response(URI.parse(url))
      Rails.logger.info(resp.ai)
    rescue Exception=>e
      return false, {'id'=>500, 'msg'=>e.to_s}
    end

    if resp.code != "200"
      return false, {'id'=>resp.code.to_i, 'msg'=>resp.message}
    end

    data = resp.body
    result = JSON.parse(data)
    if result.has_key? 'error' and not result['error'].nil?
      return false, result['error']
    else
      return true, result['plan']
    end

  end

  #TODO this is a hack. The documentation states that the transfers should be the number
  # of transfers occuring as an int. WALK returns a transfer count of -1 so we set it to
  # nil if we see this
  def fixup_transfers_count(transfers)
    transfers == -1 ? nil : transfers
  end

  def convert_itineraries(plan, mode_code='mode_transit')
    match_score = -0.3
    match_score_incr = 0.1
    plan['itineraries'].collect do |itinerary|
      trip_itinerary = {}

      returned_mode_code = mode_code
      case mode_code.to_s
        when 'mode_car'
          trip_itinerary['mode'] = Mode.car
        when 'mode_bicycle'
          trip_itinerary['mode'] = Mode.bicycle
        when 'mode_walk'
          trip_itinerary['mode'] = Mode.walk
        else
          trip_itinerary['mode'] = Mode.transit
          returned_mode_code = Mode.transit.code

          # further check if is_walk, is_car, or is_bicycle
          legs = ItineraryParser.parse(itinerary['legs'], false)
          if Itinerary.is_walk?(legs)
            returned_mode_code = Mode.walk.code
          elsif Itinerary.is_car?(legs)
            returned_mode_code = Mode.car.code
          elsif Itinerary.is_bicycle?(legs)
            returned_mode_code = Mode.bicycle.code
          end
      end

      trip_itinerary['returned_mode_code'] = returned_mode_code
      trip_itinerary['duration'] = itinerary['duration'].to_f # in seconds
      trip_itinerary['walk_time'] = itinerary['walkTime']
      trip_itinerary['transit_time'] = itinerary['transitTime']
      trip_itinerary['wait_time'] = itinerary['waitingTime']
      trip_itinerary['start_time'] = Time.at((itinerary['startTime']).to_f/1000).in_time_zone("UTC")
      trip_itinerary['end_time'] = Time.at((itinerary['endTime']).to_f/1000).in_time_zone("UTC")
      trip_itinerary['transfers'] = fixup_transfers_count(itinerary['transfers'])
      trip_itinerary['walk_distance'] = itinerary['walkDistance']
      trip_itinerary['legs'] = itinerary['legs'].to_yaml
      trip_itinerary['server_status'] = 200
      trip_itinerary['match_score'] = match_score

      begin
        #TODO: Need better documentaiton of OTP Fare Object to make this more generic
        if itinerary['fare']
          trip_itinerary['cost'] = itinerary['fare']['fare']['regular']['cents'].to_f/100.0
        end
      rescue Exception => e
        Rails.logger.info e
        Rails.logger.info itinerary['fare'].ai
        #do nothing, leave the cost element blank
      end
      agency_id = itinerary['legs'].detect{|l| !l['agencyId'].blank?}['agencyId'] rescue nil
      if agency_id
        s = Service.where(external_id: agency_id).first
        if s
          trip_itinerary['service'] = s
        end
      end
      match_score += match_score_incr
      trip_itinerary
    end
  end

  def convert_paratransit_itineraries(service, match_score = 0, missing_information = false, missing_information_text = '')
    trip_itinerary = {}
    trip_itinerary['mode'] = Mode.paratransit
    trip_itinerary['returned_mode_code'] = Mode.paratransit.code
    trip_itinerary['service'] = service
    trip_itinerary['walk_time'] = 0
    trip_itinerary['walk_distance'] = 0
    trip_itinerary['server_status'] = 200
    trip_itinerary['match_score'] = match_score
    trip_itinerary['missing_information'] = missing_information
    trip_itinerary['missing_information_text'] = missing_information_text
    trip_itinerary['missing_accommodations'] = ''
    trip_itinerary
  end

  def get_rideshare_itineraries(from, to, trip_datetime)

    t = Time.now
    query = create_rideshare_query(from, to, trip_datetime)

    agent = Mechanize.new
    agent.keep_alive=false
    agent.open_timeout = MAX_REQUEST_TIMEOUT
    agent.read_timeout = MAX_READ_TIMEOUT


    begin
      page = agent.post(service_url, query)
      doc = Nokogiri::HTML(page.body)
      results = doc.css('#results li div.marker.dest')
    rescue Exception=>e
      Rails.logger.warn "Service failure: rideshare: #{e.message}"
      Rails.logger.warn "URL was #{service_url}"
      Rails.logger.warn e.backtrace.join("\n")
      return false, {'id'=>500, 'msg'=>e.to_s, 'mode' => 'rideshare'}
    end
    if results.size > 0
      summary = doc.css('.summary').text
      Rails.logger.debug "Summary: #{summary}"
      count = %r{(\d+) total result}.match(summary)[1]
      return true, {'mode' => 'rideshare', 'status' => 200, 'count' => count, 'query' => query,
        'service' => (ServiceType.where(code: 'rideshare').first.services.first rescue nil)}
    else
      return false, {'mode' => 'rideshare', 'status' => 404, 'count' => results.size}
    end
  end

  def convert_rideshare_itineraries(itinerary)
    {
      'mode' => Mode.rideshare,
      'returned_mode_code' => Mode.rideshare.code,
      'ride_count' => itinerary['count'],
      'server_status' => itinerary['status'],
      'external_info' => YAML.dump(itinerary['query']),
      'service' => itinerary['service'],
      'match_score' => 1.1
    }
  end

  def get_drive_time arrive_by, trip_time, from_lat, from_lon, to_lat, to_lon
    tp = TripPlanner.new
    result, response = get_fixed_itineraries([from_lat, from_lon],
                                                [to_lat, to_lon], trip_time, arrive_by.to_s, 'CAR')
    itinerary = response['itineraries'].first
    return [itinerary['duration'], itinerary['legs'].to_yaml]
  end

  def get_drive_distance arrive_by, trip_time, from_lat, from_lon, to_lat, to_lon
    tp = TripPlanner.new
    result, response = get_fixed_itineraries([from_lat, from_lon],
                                                [to_lat, to_lon], trip_time, arrive_by.to_s, 'CAR')
    if response["itineraries"]
      itinerary = response['itineraries'].first
      return itinerary['legs'].first['distance'] * METERS_TO_MILES rescue nil
    else
      return nil
    end
  end

  def get_routes
    routes_path = '/index/routes'
    url = Oneclick::Application.config.open_trip_planner + routes_path
    resp = Net::HTTP.get_response(URI.parse(url))
    return JSON.parse(resp.body)
  end

end
