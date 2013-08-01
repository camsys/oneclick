require 'json'
require 'net/http'

class TripPlanner


  def get_fixed_itineraries(from, to, trip_datetime)

    #Parameters
    time = trip_datetime.strftime("%I:%M%p")
    date = trip_datetime.strftime("%Y-%m-%d")
    mode = 'TRANSIT,WALK'
    arriveBy = 'false'

    #TODO:  Move base_url for OpenTripPlanner to a global config file.
    base_url = "http://arc-otp-demo.camsys-apps.com"
    url_options = "/opentripplanner-api-webapp/ws/plan?"
    url_options += "arriveBy=" + arriveBy + "&time=" + time
    url_options += "&mode=" + mode + "&date=" + date
    url_options += "&toPlace=" + to[0].to_s + ',' + to[1].to_s + "&fromPlace=" + from[0].to_s + ',' + from[1].to_s
    url = base_url + url_options

    begin
      resp = Net::HTTP.get_response(URI.parse(url))
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

  def convert_itineraries(plan)

    plan['itineraries'].collect do |itinerary|
      trip_itinerary = {}
      trip_itinerary['mode'] = 'transit'
      trip_itinerary['duration'] = itinerary['duration'].to_f/1000
      trip_itinerary['walk_time'] = itinerary['walkTime']
      trip_itinerary['transit_time'] = itinerary['transitTime']
      trip_itinerary['wait_time'] = itinerary['waitingTime']
      trip_itinerary['start_time'] = Time.at((itinerary['startTime']).to_f/1000)
      trip_itinerary['end_time'] = Time.at((itinerary['endTime']).to_f/1000)
      trip_itinerary['transfers'] = itinerary['transfers']
      trip_itinerary['walk_distance'] = itinerary['walkDistance']
      trip_itinerary['legs'] = itinerary['legs']
      trip_itinerary['status'] = 200
      trip_itinerary
    end

  end

  def get_taxi_itineraries(from, to, trip_datetime)

    #TODO: Move the api key or url to a config
    base_url = 'http://api.taxifarefinder.com/'
    api_key = '?key=SIefr5akieS5'
    entity = '&entity_handle=Atlanta'

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
      trip_itinerary['mode'] = 'taxi'
      trip_itinerary['duration'] = itinerary[0]['duration'].to_f
      trip_itinerary['walk_time'] = 0
      trip_itinerary['walk_distance'] = 0
      trip_itinerary['cost'] = itinerary[0]['total_fare']
      trip_itinerary['status'] = 200
      trip_itinerary['message'] = itinerary[1]['businesses']
      trip_itinerary
  end

  # TODO placeholder
  def get_paratransit_itineraries(from, to, trip_datetime)
    {'mode' => 'paratransit', 'status' => 200, 'duration' => 55*60, 'cost' => 4.00}
  end

  # TODO placeholder
  def convert_paratransit_itineraries(itinerary)
    {'mode' => 'paratransit', 'status' => 200, 'duration' => 55*60, 'cost' => 4.00}
  end

end