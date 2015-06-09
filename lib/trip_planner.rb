require 'json'
require 'net/http'
require 'mechanize'

class TripPlanner

  MAX_REQUEST_TIMEOUT = Rails.application.config.remote_request_timeout_seconds
  MAX_READ_TIMEOUT    = Rails.application.config.remote_read_timeout_seconds
  METERS_TO_MILES = 0.000621371192
  
  include ServiceAdapters::RideshareAdapter

  #TODO this is a hack. The documentation states that the transfers should be the number
  # of transfers occuring as an int. WALK returns a transfer count of -1 so we set it to
  # nil if we see this
  def fixup_transfers_count(transfers)
    transfers == -1 ? nil : transfers
  end

  def convert_itineraries(plan, mode_code='mode_transit')

    match_score = -0.3
    match_score_incr = 0.1

    plan['itineraries'].collect do |otp_itinerary|

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
          legs = OTPService.parse_otp_legs(otp_itinerary['legs'], false)

          if Itinerary.is_walk?(legs)
            returned_mode_code = Mode.walk.code
          elsif Itinerary.is_car?(legs)
            returned_mode_code = Mode.car.code
          elsif Itinerary.is_bicycle?(legs)
            returned_mode_code = Mode.bicycle.code
          end
          
      end

      trip_itinerary['returned_mode_code'] = returned_mode_code
      trip_itinerary['duration'] = otp_itinerary['duration'].to_f # in seconds
      trip_itinerary['walk_time'] = otp_itinerary['walkTime']
      trip_itinerary['transit_time'] = otp_itinerary['transitTime']
      trip_itinerary['wait_time'] = otp_itinerary['waitingTime']
      trip_itinerary['start_time'] = Time.at((otp_itinerary['startTime']).to_f/1000).in_time_zone("UTC")
      trip_itinerary['end_time'] = Time.at((otp_itinerary['endTime']).to_f/1000).in_time_zone("UTC")
      trip_itinerary['transfers'] = fixup_transfers_count(otp_itinerary['transfers'])
      trip_itinerary['walk_distance'] = otp_itinerary['walkDistance']

      #handle legs
      #trip_itinerary['legs'] = create_legs(otp_itinerary['legs'])

      trip_itinerary['server_status'] = 200
      trip_itinerary['match_score'] = match_score

      begin
        #TODO: Need better documentaiton of OTP Fare Object to make this more generic
        trip_itinerary['cost'] = otp_itinerary['fare']['fare']['regular']['cents'].to_f/100.0
      rescue Exception => e
        Rails.logger.error e
        Rails.logger.error otp_itinerary['fare'].ai
        #do nothing, leave the cost element blank
      end

      agency_id = otp_itinerary['legs'].detect{|l| !l['agencyId'].blank?}['agencyId'] rescue nil
      if agency_id
        s = Service.where(external_id: agency_id).first
        if s
          trip_itinerary['service'] = s
        end
      end

      match_score += match_score_incr
      
      Itinerary.create!(trip_itinerary)

    end

  end

  def create_legs(otp_legs)

    parsed_legs = OTPService.parse_otp_legs(otp_legs)

    parsed_legs.each do |otp_leg|
      new_leg = Leg.new
    end

    return otp_legs.to_yaml
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
      Honeybadger.notify(
        :error_class   => "Service failure",
        :error_message => "Service failure: rideshare: #{e.message}, URL was #{service_url}",
        :parameters    => {service_url: service_url, query: query}
      )
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
    result, response = OTPService.get_fixed_itineraries([from_lat, from_lon],
                                                [to_lat, to_lon], trip_time, arrive_by.to_s, 'CAR')
    itinerary = response['itineraries'].first
    return [itinerary['duration'], itinerary['legs'].to_yaml]
  end

  def get_drive_distance arrive_by, trip_time, from_lat, from_lon, to_lat, to_lon
    tp = TripPlanner.new
    result, response = OTPService.get_fixed_itineraries([from_lat, from_lon],
                                                [to_lat, to_lon], trip_time, arrive_by.to_s, 'CAR')
    itinerary = response['itineraries'].first
    return itinerary['legs'].first['distance'] * METERS_TO_MILES rescue nil
  end

end
