#
# Parses a YAML loaded collection of legs from the itinerary table and generates an array
# of leg objects
#
# TODO This class is mis-named; should really be ItineraryLegParser

class ItineraryParser

  def self.parse(legs, include_geometry = true)

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

protected

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
    elsif leg['mode'].in? ['BUS', 'FERRY', 'TRAM', 'RAIL', 'SUBWAY']
      obj = parse_transit_leg(leg)
    end

    # parse the common properties
    if obj
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

    sub = Leg::TransitLeg.new
    sub.mode = leg['mode']
    sub.agency_name = leg['agencyName']
    agencyId = leg['agencyId']
    s = Service.where(external_id: agencyId).first
    if s
      sub.agency_id = s.name
    else
      sub.agency_id = leg['agencyId']
    end

    sub.head_sign = leg['headsign']
    sub.route = leg['route']
    sub.route_id = leg['routeId']
    sub.route_short_name = leg['routeShortName']
    sub.route_long_name = leg['routeLongName']

    return sub
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
