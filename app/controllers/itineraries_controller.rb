class ItinerariesController < ApplicationController

  def hide
    @itinerary = Itinerary.find(params[:id])
    if @itinerary.hide
      render json: {id: @itinerary.id}
    else
      render text: 'Unable to remove itinerary.', status: 500

    end
  end

end
