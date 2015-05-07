class TaxiRestService

  def self.call_out_to_taxi_fare_finder(city, api_key, from, to)

	base_url = "http://api.taxifarefinder.com/"

  	entity = '&entity_handle=' + city
  	api_key = '?key=' + api_key
    fare_options = "&origin=" + to[0].to_s + ',' + to[1].to_s + "&destination=" + from[0].to_s + ',' + from[1].to_s

    #FARE TASK
  	task = 'fare'

    url = base_url + task + api_key + entity + fare_options

  	Rails.logger.info "TripPlanner#get_taxi_itineraries-fare: url: #{url}"

    begin
      resp = Net::HTTP.get_response(URI.parse(url))
    rescue Exception=>e
      log_error_to_honeybadger("Service failure: taxi: #{e.message}",{url: url, resp: resp})
      return Itinerary.new('server_status'=>500, 'server_message'=>e.to_s)
    end

    Rails.logger.debug "TripPlanner#get_taxi_itineraries: resp.body: #{resp.body}"

    fare = JSON.parse(resp.body)
    if fare['status'] != "OK"
      log_error_to_honeybadger("Service failure: taxi: fare status not OK",{fare: fare})
      return Itinerary.new('server_status'=>500, 'server_message'=>fare['explanation'].to_s)
    end

    #Get providers
    task = 'businesses'
    url = base_url + task + api_key + entity

    Rails.logger.info "TripPlanner#get_taxi_itineraries-business: url: #{url}"

    begin
      resp = Net::HTTP.get_response(URI.parse(url))
    rescue Exception=>e
      log_error_to_honeybadger("Service failure: taxi: #{e.message}",{resp: resp})
      return Itinerary.new('server_status'=>500, 'server_message'=>e.to_s)
    end

    Rails.logger.debug "TripPlanner#get_taxi_itineraries: resp.body: #{resp.body}"

    businesses = JSON.parse(resp.body)

    if businesses['status'] != "OK"
      log_error_to_honeybadger("Service failure: taxi: business status not OK",{businesses:businesses})
      return Itinerary.new('server_status'=>500, 'server_message'=>businesses['explanation'].to_s)
    else
      return format_response_object([fare, businesses])
    end

  end

  def self.log_error_to_honeybadger(message, params)
  	  Honeybadger.notify(
        :error_class   => "Service failure",
        :error_message => message,
        :parameters    => params
      )
  end

  def self.format_response_object(response_object)

    trip_itinerary = {}
    trip_itinerary['mode'] = Mode.taxi
    trip_itinerary['returned_mode_code'] = Mode.taxi.code
    trip_itinerary['duration'] = response_object[0]['duration'].to_f
    trip_itinerary['walk_time'] = 0
    trip_itinerary['walk_distance'] = 0
    trip_itinerary['cost'] = response_object[0]['total_fare']
    trip_itinerary['server_status'] = 200
    trip_itinerary['server_message'] = response_object[1]['businesses'].to_yaml
    trip_itinerary['match_score'] = 1.2
    trip_itinerary['service'] = (ServiceType.where(code: 'taxi').first.services.first rescue nil)
    Itinerary.new(trip_itinerary)

  end

end