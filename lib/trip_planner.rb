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
      trip_itinerary['duration'] = itinerary['duration']
      trip_itinerary['walk_time'] = itinerary['walkTime']
      trip_itinerary['transit_time'] = itinerary['transitTime']
      trip_itinerary['wait_time'] = itinerary['waitingTime']
      trip_itinerary['start_time'] = Time.at((itinerary['startTime'])/1000)
      trip_itinerary['end_time'] = Time.at((itinerary['endTime'])/1000)
      trip_itinerary['transfers'] = itinerary['transfers']
      trip_itinerary['walk_distance'] = itinerary['walkDistance']
      trip_itinerary['legs'] = itinerary['legs']
      trip_itinerary['status'] = 200
      trip_itinerary
    end

  end

end