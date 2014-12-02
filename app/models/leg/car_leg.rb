#
# Concrete implementation of a walking leg
#
module Leg
  class CarLeg < TripLeg

    attr_accessor :steps

    def initialize(attrs = {})

      super(attrs)
      attrs.each do |k, v|
        self.send "#{k}=", v
      end

      self.mode = CAR

    end

    def short_description
      [I18n.t(:drive_or_taxi), I18n.t(:to), end_place.name].join(' ')
    end

    def trip_steps
      html = "<div data-toggle='collapse' data-target='#drivingDirections'><a>" + short_description + "</a></div>
              <div id='drivingDirections' class='panel-body collapse'>"

      steps.each do |hash|
        html << "<p>"
        html << hash["relativeDirection"].to_s
        html << " on to "
        html << hash["streetName"].to_s
        html << ", "
        html << (hash["distance"] * 0.000621371).round(2).to_s
        html << " miles </br></p>"
      end

      html << "</div>"
      return html.html_safe
    end

  end
end
