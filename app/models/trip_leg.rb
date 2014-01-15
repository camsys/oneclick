#
# Abstract transient class for storing information about a leg of an itinerary
#
#
class TripLeg
  
  WALK    = 'WALK'
  TRAM    = 'TRAM'
  SUBWAY  = 'SUBWAY'
  RAIL    = 'RAIL'
  BUS     = 'BUS'
  FERRY   = 'FERRY'
   
  # Type of mode
  attr_accessor :mode

  # Start time for the leg. Localized
  attr_accessor :start_time
  # End time for the leg. Localized
  attr_accessor :end_time
  # Distance of the leg in Km
  attr_accessor :distance
  # Calculated length of the leg in seconds 
  attr_accessor :duration

  # Starting place for the leg
  attr_accessor :start_place
  # Terminating place for the leg
  attr_accessor :end_place
  
  # array of points that make a polyline shape for the leg
  attr_accessor :geometry

  def route
    "n/a"
  end

  def route_id
    "n/a"
  end
    
  #  
  def initialize(attrs = {})
    attrs.each do |k, v|
      self.send "#{k}=", v
    end
  end
    
  def duration
    return end_time - start_time
  end
end