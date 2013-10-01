class BusLeg < TripLeg
  
  attr_accessor :route
  attr_accessor :route_short_name
  attr_accessor :route_long_name
  attr_accessor :route_id
  attr_accessor :head_sign
  attr_accessor :agency_name
  attr_accessor :agency_id
      
  def initialize(attrs = {})
    super(attrs)
    attrs.each do |k, v|
      self.send "#{k}=", v
    end
    
    self.type = BUS

  end
  
end
