#
# Concrete implementation of a walking leg
#
class WalkLeg < TripLeg
    
  def initialize(attrs = {})

    super(attrs)
    attrs.each do |k, v|
      self.send "#{k}=", v
    end
    
    self.mode = WALK
    
  end
  
end
