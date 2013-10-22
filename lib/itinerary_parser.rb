#
# Parses a YAML loaded collection of legs from the itinerary table and generates an array
# of leg objects
#
class ItineraryParser
  
  def self.parse(legs)
    
    Rails.logger.debug "Parsing Itinerary Legs"
    
    itin = []
    
    legs.each do |leg|
      leg_itin = parse_leg(leg)
      
      Rails.logger.debug leg_itin.inspect
      
      itin << leg_itin unless leg_itin.nil?
    end
    
    return itin
    
  end
  
protected

  def self.parse_leg(leg)
    
    return if leg.blank?
    
    Rails.logger.debug "Leg mode = " + leg['mode']
    Rails.logger.debug "Leg = " + leg.inspect
    
    if leg['mode'] == 'WALK'
      obj = parse_walk_leg(leg)
    elsif leg['mode'] == 'BUS'
      obj = parse_bus_leg(leg)
    elsif leg['mode'] == 'SUBWAY'
      obj = parse_subway_leg(leg)
    end
    
    # parse the common properties
    if obj
      obj.distance = leg['distance'].to_f
      obj.start_time = convert_time(leg['startTime'])
      obj.end_time = convert_time(leg['endTime'])
      obj.duration = leg['duration'].to_i / 1000

      obj.start_place = parse_place(leg['from'])
      obj.end_place = parse_place(leg['to'])  

      obj.geometry = parse_geometry(leg['legGeometry'])
    end
    
    return obj
  end

  def self.parse_subway_leg(leg)
    
    Rails.logger.debug "Parsing SUBWAY leg"
    
    sub = SubwayLeg.new

    sub.agency_name = leg['agencyName']
    sub.agency_id = leg['agencyId']

    sub.head_sign = leg['headsign']
    sub.route = leg['route']
    sub.route_id = leg['routeId']
    sub.route_short_name = leg['routeShortName']
    sub.route_long_name = leg['routeLongName']
    
    return sub    
  end

  def self.parse_bus_leg(leg)

    Rails.logger.debug "Parsing BUS leg"
    
    bus = BusLeg.new

    bus.agency_name = leg['agencyName']
    bus.agency_id = leg['agencyId']

    bus.head_sign = leg['headsign']
    bus.route = leg['route']
    bus.route_id = leg['routeId']
    bus.route_short_name = leg['routeShortName']
    bus.route_long_name = leg['routeLongName']
    
    return bus
        
  end
  
  def self.parse_walk_leg(leg)

    Rails.logger.debug "Parsing WALK leg"
    
    walk = WalkLeg.new    
    return walk
    
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