#
# Concrete implementation of a walking leg
#
module Leg
  class WalkLeg < TripLeg

    def initialize(attrs = {})

      super(attrs)
      attrs.each do |k, v|
        self.send "#{k}=", v
      end

      self.mode = WALK

    end

    def short_description
      desc = [I18n.t(mode.downcase.to_sym), I18n.t(:to), end_place.name].join(' ')
    end

  end
end
