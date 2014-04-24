#
# Concrete implementation of a walking leg
#
class CarLeg < TripLeg
    
  def initialize(attrs = {})

    super(attrs)
    attrs.each do |k, v|
      self.send "#{k}=", v
    end
    
    self.mode = CAR
    
  end
  
end
