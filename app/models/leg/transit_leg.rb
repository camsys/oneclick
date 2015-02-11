module Leg
  class TransitLeg < TripLeg

    TRANSIT_LEGS = [TRAM, SUBWAY, RAIL, BUS, FERRY]

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
      agency = agency_id.nil? ? nil : agency_id
      route_name = route_short_name || route_long_name
      if head_sign and head_sign.include? route_name
        [agency, I18n.t(mode.downcase.to_sym), head_sign, I18n.t(:to), end_place.name].join(' ')
      elsif head_sign
        [agency, I18n.t(mode.downcase.to_sym), I18n.t(:route), route_name, '(' + head_sign + ')', I18n.t(:to), end_place.name].join(' ')
      else
        [agency, I18n.t(mode.downcase.to_sym), I18n.t(:route), route_name, "", I18n.t(:to), end_place.name].join(' ')
      end
    end

  end
end
