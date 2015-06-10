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



  def self.parse_and_create_otp_legs(itinerary, legs, include_geometry = true)

    Rails.logger.debug "Parsing Itinerary Legs"

    if legs.is_a? Array
      legs.each do |leg|
        parse_and_create_leg(itinerary.id, leg, include_geometry)
      end
    end

    if itinerary.is_walk?(legs)
      returned_mode_code = Mode.walk.code
    elsif itinerary.is_car?
      returned_mode_code = Mode.car.code
    elsif itinerary.is_bicycle?
      returned_mode_code = Mode.bicycle.code
    end

    itinerary['returned_mode_code'] = returned_mode_code

    itinerary.save

  end

  def self.parse_and_create_leg(itinerary_id, leg, include_geometry = true)

    return if leg.blank?

    Rails.logger.debug "Leg mode = " + leg['mode']
    Rails.logger.debug "Leg = " + leg.inspect

    if leg['mode'] == 'WALK'
      new_leg = parse_walk_leg(leg)
    elsif leg['mode'] ==  'CAR'
      new_leg = parse_car_leg(leg)
    elsif leg['mode'] == 'BICYCLE'
      new_leg = parse_bicycle_leg(leg)
    elsif leg['mode'].in? TransitLeg::TRANSIT_LEGS
      new_leg = parse_transit_leg(leg)
    end

    # parse the common properties
    if new_leg.present?

      new_leg.distance = leg['distance'].to_f
      new_leg.start_time = convert_time(leg['startTime'])
      new_leg.end_time = convert_time(leg['endTime'])
      new_leg.duration = leg['duration'].to_i / 1000

      new_leg.start_place = parse_place(leg['from'])
      new_leg.end_place = parse_place(leg['to'])

      new_leg.geometry = parse_geometry(leg['legGeometry']) if include_geometry
      
    end

    new_leg.itinerary_id_id = itinerary_id

    return new_leg

  end

  def self.parse_transit_leg(leg)

    Rails.logger.debug "Parsing TRANSIT leg"

    new_transit_leg = TransitLeg.new
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

    new_transit_leg.save

    return new_transit_leg

  end

  def self.parse_walk_leg(leg)

    Rails.logger.debug "Parsing WALK leg"

    walk_leg = WalkLeg.new
    walk_leg.steps = leg['steps']
    walk_leg.save

    return walk_leg

  end

  def self.parse_bicycle_leg(leg)

    Rails.logger.debug "Parsing BICYCLE leg"

    bicycle = BicycleLeg.new
    bicycle.steps = leg['steps']
    return bicycle

  end

  def self.parse_car_leg(leg)
    Rails.logger.debug "Parsing CAR leg"

    car = CarLeg.new
    car.steps = leg['steps']
    return car

  end

  def self.parse_place(place_part)

    place = LegPlace.new
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