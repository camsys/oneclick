require 'json'
require 'net/http'

class TripPlanner

  def create_itineraries_from_trip(trip)
      result, plan = get_fixed_itinerary([trip.to_place.lat, trip.to_place.lon],[trip.from_place.lat, trip.from_place.lon], trip.trip_datetime)
      if result
        store_itinerary(trip,plan)
      end
  end

  def get_fixed_itinerary(from, to, trip_datetime)

    #Parameters
    time = trip_datetime.strftime("%I:%M%p")
    date = trip_datetime.strftime("%Y-%m-%d")
    mode = 'TRANSIT,WALK'
    arriveBy = 'false'

    #TODO:  Move base_url for OpenTripPlanner to a global config file.
    base_url = "http://arc-otp-demo.camsys-apps.com/opentripplanner-api-webapp/ws/plan?"
    url_options = "arriveBy=" + arriveBy + "&time=" + time
    url_options += "&mode=" + mode + "&date=" + date
    url_options += "&toPlace=" + to[0].to_s + ',' + to[1].to_s + "&fromPlace=" + from[0].to_s + ',' + from[1].to_s
    url = base_url + url_options

    resp = Net::HTTP.get_response(URI.parse(url))
    data = resp.body

    result = JSON.parse(data)
    if result.has_key? 'error'
      return false, result['error']['msg']
    else
      return true, result['plan']
    end

  end

  def store_itinerary(trip, plan)

    JSON.parse(plan['itineraries'].to_json).each do |itinerary|
      trip_itinerary = Itinerary.new()
      trip_itinerary.duration = itinerary['duration']/1000
      trip_itinerary.walk_time = itinerary['walkTime']
      trip_itinerary.transit_time = itinerary['transitTime']
      trip_itinerary.wait_time = itinerary['waitingTime']
      trip_itinerary.start_time = Time.at((itinerary['startTime'])/1000)
      trip_itinerary.end_time = Time.at((itinerary['endTime'])/1000)
      trip_itinerary.transfers = itinerary['transfers']
      trip_itinerary.walk_distance = itinerary['walkDistance']
      trip_itinerary.trip = trip
      #TODO Change length of LEGS column in DB
      trip_itinerary.save()
    end

  end

end