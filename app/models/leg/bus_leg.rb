module Leg
  class BusLeg < TransitLeg

    def initialize(attrs = {})
      super(attrs)
      self.mode = BUS
    end

  end
end
