module Kiosk
  class TripsController < ::TripsController
    include Behavior

    def start
      get_traveler
      get_trip

      @trip_proxy = create_trip_proxy(@trip)
    end
  end
end
