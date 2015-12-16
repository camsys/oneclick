class RideHailingItinerary < Itinerary
  def self.get_itineraries(trip_part)
    services = get_ride_hailing_services
    itins = []

    ride_hailing_mode = Mode.ride_hailing

    services.each do |service|
      case service.service_type.try(:code)
      when 'uber_x'
        next if !UberHelpers.available?
        new_itin = UberItinerary.new(service: service, trip_part: trip_part, mode: ride_hailing_mode, returned_mode_code: 'mode_ride_hailing')
        new_itin.service = service
        new_itin.trip_part = trip_part
        new_itin.formulate

        new_itin.save

        itins << new_itin
      end
    end

    itins
  end

  private

  def self.get_ride_hailing_services
    Service.active.ride_hailing
  end
end