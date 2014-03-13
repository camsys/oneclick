module Kiosk
  class TripsController < ::TripsController
    include Behavior

    def show
      if params[:back]
        session[:current_trip_id] = @trip.id
        redirect_to new_user_characteristic_path_for_ui_mode(@traveler, inline: 1)
        return
      end

      super
    end

    def itinerary_print
      @itinerary = Itinerary.find(params[:id])
      @legs = @itinerary.get_legs
      @itinerary = ItineraryDecorator.decorate(@itinerary)
      @hide_timeout = true
    end

  protected

    def back_url
      if params[:action] == 'show'
        url_for(back: true)
      end
    end
  end
end
