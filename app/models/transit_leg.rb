class TransitLeg < Leg

    TRANSIT_LEGS = [TRAM, SUBWAY, RAIL, BUS, FERRY, CABLE_CAR, GONDOLA, FUNICULAR]
    RAIL_LEGS = [TRAM, SUBWAY, RAIL, CABLE_CAR, GONDOLA, FUNICULAR]

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
        [agency, TranslationEngine.translate_text(mode.downcase.to_sym), head_sign, TranslationEngine.translate_text(:to), end_place.name].join(' ')
      elsif head_sign
        [agency, TranslationEngine.translate_text(mode.downcase.to_sym), TranslationEngine.translate_text(:route), route_name, '(' + head_sign + ')', TranslationEngine.translate_text(:to), end_place.name].join(' ')
      else
        [agency, TranslationEngine.translate_text(mode.downcase.to_sym), TranslationEngine.translate_text(:route), route_name, "", TranslationEngine.translate_text(:to), end_place.name].join(' ')
      end
    end

end