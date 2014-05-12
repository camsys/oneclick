module Leg
  class RailLeg < TransitLeg

    def initialize(attrs = {})
      super(attrs)
      self.mode = RAIL
    end

  end
end
