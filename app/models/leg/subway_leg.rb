module Leg
  class SubwayLeg < TransitLeg

    def initialize(attrs = {})
      super(attrs)
      self.mode = SUBWAY
    end

  end
end
