require 'json'
require 'net/http'
require 'mechanize'

class TripPlanner

  MAX_REQUEST_TIMEOUT = Rails.application.config.remote_request_timeout_seconds
  MAX_READ_TIMEOUT    = Rails.application.config.remote_read_timeout_seconds
  
  include ServiceAdapters::RideshareAdapter

  def get_fixed_itineraries(from, to, trip_datetime, arriveBy)

    #Parameters
    time = trip_datetime.strftime("%-I:%M%p")
    date = trip_datetime.strftime("%Y-%m-%d")
    mode = 'TRANSIT,WALK'

    base_url = Oneclick::Application.config.open_trip_planner
    url_options = "/opentripplanner-api-webapp/ws/plan?"
    url_options += "arriveBy=" + arriveBy + "&time=" + time
    url_options += "&mode=" + mode + "&date=" + date
    url_options += "&toPlace=" + to[0].to_s + ',' + to[1].to_s + "&fromPlace=" + from[0].to_s + ',' + from[1].to_s
    url = base_url + url_options

    Rails.logger.debug URI.parse(url)
    
    begin
      resp = Net::HTTP.get_response(URI.parse(url))
      Rails.logger.info(resp.inspect)
    rescue Exception=>e
      return false, {'id'=>500, 'msg'=>e.to_s}
    end

    if resp.code != "200"
      return false, {'id'=>resp.code.to_i, 'msg'=>resp.message}
    end

    data = resp.body
    result = JSON.parse(data)
    if result.has_key? 'error'
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
  def convert_itineraries(plan)

    plan['itineraries'].collect do |itinerary|
      trip_itinerary = {}
      trip_itinerary['mode'] = Mode.transit
      trip_itinerary['duration'] = itinerary['duration'].to_f/1000
      trip_itinerary['walk_time'] = itinerary['walkTime']
      trip_itinerary['transit_time'] = itinerary['transitTime']
      trip_itinerary['wait_time'] = itinerary['waitingTime']
      trip_itinerary['start_time'] = Time.at((itinerary['startTime']).to_f/1000)
      trip_itinerary['end_time'] = Time.at((itinerary['endTime']).to_f/1000)
      trip_itinerary['transfers'] = fixup_transfers_count(itinerary['transfers'])
      trip_itinerary['walk_distance'] = itinerary['walkDistance']
      trip_itinerary['legs'] = itinerary['legs']
      trip_itinerary['server_status'] = 200
      trip_itinerary
    end

  end

  def get_taxi_itineraries(from, to, trip_datetime)

    base_url = "http://api.taxifarefinder.com/"
    api_key = Oneclick::Application.config.taxi_fare_finder_api_key
    api_key = '?key=' + api_key
    city = Oneclick::Application.config.taxi_fare_finder_api_city
    entity = '&entity_handle=' + city

    #Get fare
    task = 'fare'
    fare_options = "&origin=" + to[0].to_s + ',' + to[1].to_s + "&destination=" + from[0].to_s + ',' + from[1].to_s
    url = base_url + task + api_key + entity + fare_options
    begin
      resp = Net::HTTP.get_response(URI.parse(url))
    rescue Exception=>e
      return false, {'id'=>500, 'msg'=>e.to_s}
    end

    fare = JSON.parse(resp.body)
    if fare['status'] != "OK"
      return false, fare['explanation']
    end

    #Get providers
    task = 'businesses'
    url = base_url + task + api_key + entity
    begin
      resp = Net::HTTP.get_response(URI.parse(url))
    rescue Exception=>e
      return false, {'id'=>500, 'msg'=>e.to_s}
    end

    businesses = JSON.parse(resp.body)
    if businesses['status'] != "OK"
      return false, businesses['explanation']
    else
      return true, [fare, businesses]
    end

  end

  def convert_taxi_itineraries(itinerary)
    trip_itinerary = {}
    trip_itinerary['mode'] = Mode.taxi
    trip_itinerary['duration'] = itinerary[0]['duration'].to_f
    trip_itinerary['walk_time'] = 0
    trip_itinerary['walk_distance'] = 0
    trip_itinerary['cost'] = itinerary[0]['total_fare']
    trip_itinerary['server_status'] = 200
    trip_itinerary['server_message'] = itinerary[1]['businesses']
    trip_itinerary
  end

  def convert_paratransit_itineraries(service)
    trip_itinerary = {}
    trip_itinerary['mode'] = Mode.paratransit
    trip_itinerary['service'] = service
    trip_itinerary['walk_time'] = 0
    trip_itinerary['walk_distance'] = 0
    trip_itinerary['server_status'] = 200

    trip_itinerary

  end

  def get_rideshare_itineraries(from, to, trip_datetime)
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
      Rails.logger.warn e.to_s
      return false, {'id'=>500, 'msg'=>e.to_s}
    end    
    if results.size > 0
      summary = doc.css('.summary').text
      Rails.logger.debug "Summary: #{summary}"
      count = %r{(\d+) total result}.match(summary)[1]
      return true, {'mode' => 'rideshare', 'status' => 200, 'count' => count, 'query' => query}
    else
      return false, {'mode' => 'rideshare', 'status' => 404, 'count' => results.size}
    end
  end

  def convert_rideshare_itineraries(itinerary)
    {
      'mode' => Mode.rideshare,
      'ride_count' => itinerary['count'],
      'server_status' => itinerary['status'],
      'external_info' => YAML.dump(itinerary['query'])
    }
  end

end