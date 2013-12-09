class TripPartsController < PlaceSearchingController
  include TripsSupport

  before_filter :get_traveler
  before_filter :get_trip

  # Unhides all the hidden itineraries for a trip part
  def unhide_all
    trip_part = TripPart.find(params[:id])
    trip_part.itineraries.valid.hidden.each do |i|
      i.hidden = false
      i.save
    end
    redirect_to user_trip_path(@traveler, trip_part.trip)
  end

end
