#
# Abstract transient class for storing information about a leg of an itinerary
#
#
class TripLeg
  
  WALK    = 'walk'
  BUS     = 'bus'
  SUBWAY = 'subway'
   
  # Type of mode
  attr_accessor :type

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
    
  #  
  def initialize(attrs = {})
    attrs.each do |k, v|
      self.send "#{k}=", v
    end
  end
    
end