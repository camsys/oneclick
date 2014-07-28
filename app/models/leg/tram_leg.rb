module Leg
  class TramLeg < TransitLeg

    def initialize(attrs = {})
      super(attrs)
      self.mode = TRAM
    end

  end
end
