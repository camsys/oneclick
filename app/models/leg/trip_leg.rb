#
# Abstract transient class for storing information about a leg of an itinerary
#
#
module Leg
  class TripLeg

    #Transit Modes and Rail Modes should be Added to TransitLeg
    WALK    = 'WALK'
    TRAM    = 'TRAM'
    SUBWAY  = 'SUBWAY'
    RAIL    = 'RAIL'
    BUS     = 'BUS'
    FERRY   = 'FERRY'
    CAR     = 'CAR'
    BICYCLE  = 'BICYCLE'
    CABLE_CAR = 'CABLE_CAR'
    GONDOLA = 'GONDOLA'
    FUNICULAR = 'FUNICULAR'


    # Type of mode
    attr_accessor :mode

    # Start time for the leg. Localized
    attr_accessor :start_time
    # End time for the leg. Localized
    attr_accessor :end_time
    # Distance of the leg in Km
    attr_accessor :distance
    # Calculated length of the leg in seconds
    attr_accessor :duration

    # Starting place for the leg
    attr_accessor :start_place
    # Terminating place for the leg
    attr_accessor :end_place

    # array of points that make a polyline shape for the leg
    attr_accessor :geometry

    # array of steps for driving/walking/biking directions
    attr_accessor :steps
    attr_accessor :display_color

    attr_accessor :agency_id

    def route
      "n/a"
    end

    def route_id
      "n/a"
    end

    #
    def initialize(attrs = {})
      attrs.each do |k, v|
        self.send "#{k}=", v
      end
    end

    def duration
      return end_time - start_time
    end

    def color
      self.display_color
    end

    def trip_steps
      html = "<div data-toggle='collapse' data-target='#drivingDirections'><a class='drivingDirectionsLink'>" + short_description + "</a></div>
              <div id='drivingDirections' class='panel-body collapse'>"

      steps.each do |hash|
        html << "<p>"
        html << I18n.t(hash["relativeDirection"].downcase.to_sym)
        html << " #{I18n.t(:on_to)} "
        html << hash["streetName"].to_s
        html << ", "
        html << (hash["distance"] * 0.000621371).round(2).to_s
        html << " #{I18n.t(:miles)} </br></p>"
      end

      html << "</div>"
      return html.html_safe
    end

  end
end
