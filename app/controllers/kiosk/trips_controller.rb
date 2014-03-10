module Kiosk
  class TripsController < ::TripsController
    include Behavior

    def itinerary_print
      @itinerary = Itinerary.find(params[:id])
      @legs = @itinerary.get_legs
      @itinerary = ItineraryDecorator.decorate(@itinerary)
      @hide_timeout = true
    end

  protected

    def back_url
      if params[:action] == 'show'
        '/'
      end
    end
  end
end
