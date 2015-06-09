class OTPService

def self.get_fixed_itineraries(from, to, trip_datetime, arriveBy, mode="TRANSIT,WALK", wheelchair="false", walk_speed=3.0, max_walk_distance=2, try_count=Oneclick::Application.config.OTP_retry_count)
    try = 1
    result = nil
    response = nil

    while try <= try_count
      result, response = self.get_fixed_itineraries_once(from, to, trip_datetime, arriveBy, mode, wheelchair, walk_speed, max_walk_distance)
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

  def self.parse_otp_legs(legs, include_geometry = true)

    Rails.logger.debug "Parsing Itinerary Legs"

    itin = []

    if legs.is_a? Array
      legs.each do |leg|
        leg_itin = parse_leg(leg, include_geometry)

        Rails.logger.debug leg_itin.inspect

        itin << leg_itin unless leg_itin.nil?
      end
    end

    return itin

  end

  def self.parse_leg(leg, include_geometry = true)

    return if leg.blank?

    Rails.logger.debug "Leg mode = " + leg['mode']
    Rails.logger.debug "Leg = " + leg.inspect

    if leg['mode'] == 'WALK'
      obj = parse_walk_leg(leg)
    elsif leg['mode'] ==  'CAR'
      obj = parse_car_leg(leg)
    elsif leg['mode'] == 'BICYCLE'
      obj = parse_bicycle_leg(leg)
    elsif leg['mode'].in? Leg::TransitLeg::TRANSIT_LEGS
      obj = parse_transit_leg(leg)
    end

    # parse the common properties
    if obj.present?

      obj.distance = leg['distance'].to_f
      obj.start_time = convert_time(leg['startTime'])
      obj.end_time = convert_time(leg['endTime'])
      obj.duration = leg['duration'].to_i / 1000

      obj.start_place = parse_place(leg['from'])
      obj.end_place = parse_place(leg['to'])

      obj.geometry = parse_geometry(leg['legGeometry']) if include_geometry
      
    end

    return obj
  end

  def self.parse_transit_leg(leg)

    Rails.logger.debug "Parsing TRANSIT leg"

    new_transit_leg = Leg::TransitLeg.new
    new_transit_leg.mode = leg['mode']
    new_transit_leg.agency_name = leg['agencyName']
    agencyId = leg['agencyId']

    leg_service = Service.where(external_id: agencyId).first

    if leg_service.present?
      new_transit_leg.agency_id = leg_service.name
      use_gtfs_color = leg_service.use_gtfs_colors if leg_service.use_gtfs_colors.present?
      use_gtfs_colors ||= false
      new_transit_leg.display_color = leg_service.display_color if leg_service.display_color.present?
      new_transit_leg.display_color ||= leg['routeColor'] unless (leg['routeColor'].nil? || leg['routeColor'].blank? || !leg_service.use_gtfs_colors)
      if new_transit_leg.display_color.present?
        new_transit_leg.display_color = "#" + new_transit_leg.display_color if (new_transit_leg.display_color.index("#") != 0)
      end
    else
      new_transit_leg.agency_id = leg['agencyId']
    end 

    new_transit_leg.head_sign = leg['headsign']
    new_transit_leg.route = leg['route']
    new_transit_leg.route_id = leg['routeId']
    new_transit_leg.route_short_name = leg['routeShortName']
    new_transit_leg.route_long_name = leg['routeLongName']

    return new_transit_leg

  end

  def self.parse_walk_leg(leg)

    Rails.logger.debug "Parsing WALK leg"

    walk = Leg::WalkLeg.new
    walk.steps = leg['steps']
    return walk

  end

  def self.parse_bicycle_leg(leg)

    Rails.logger.debug "Parsing BICYCLE leg"

    bicycle = Leg::BicycleLeg.new
    bicycle.steps = leg['steps']
    return bicycle

  end

  def self.parse_car_leg(leg)
    Rails.logger.debug "Parsing CAR leg"

    car = Leg::CarLeg.new
    car.steps = leg['steps']
    return car

  end

  def self.parse_place(place_part)

    place = Leg::LegPlace.new
    place.name = place_part['name']
    place.lat = place_part['lat'].to_f
    place.lon = place_part['lon'].to_f

    return place
  end

  def self.convert_time(time)
    Time.at(time.to_i/1000).in_time_zone
  end

  #
  # Parses the leg geometry using the Polyline gem. The geometry is encoded using
  # Googles polyline encoding algorithm.
  def self.parse_geometry(geom)
    length = geom['length'].to_i
    encoded_points = geom['points']
    return Polylines::Decoder.decode_polyline(encoded_points)
  end

end