module Leg
  class TransitLeg < TripLeg

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
    end

    def short_description
      route_name = route_short_name || route_long_name
      if head_sign and head_sign.include? route_name
        [I18n.t(mode.downcase.to_sym), head_sign, I18n.t(:to), end_place.name].join(' ')
      else
        [I18n.t(mode.downcase.to_sym), I18n.t(:route), route_name, '(' + head_sign + ')', I18n.t(:to), end_place.name].join(' ')
      end
    end

  end
end
