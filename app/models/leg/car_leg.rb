#
# Concrete implementation of a walking leg
#
module Leg
  class CarLeg < TripLeg

    def initialize(attrs = {})

      super(attrs)
      attrs.each do |k, v|
        self.send "#{k}=", v
      end

      self.mode = CAR

    end

    def short_description
      [I18n.t(:drive), I18n.t(:to), end_place.name].join(' ')
    end

  end
end
