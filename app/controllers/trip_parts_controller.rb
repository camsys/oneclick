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
    redirect_to user_trip_path_for_ui_mode(@traveler, trip_part.trip)
  end

  def itineraries
    @trip_part = TripPart.find(params[:id])
    @modes = Mode.where(code: params[:mode])
    params[:regen] = (params[:regen] || true).to_bool
    if params[:regen]
      @trip_part.remove_existing_itineraries(@modes)
      @itineraries = @trip_part.create_itineraries(@modes)
    end
    if @itineraries.each {|i| i.save }
      respond_to do |f|
        f.json { render json: @itineraries, root: 'itineraries', each_serializer: ItinerarySerializer }
      end
    else
      respond_to do |f|
        f.json {
          render json:       {
            status: 0,
            status_text: @itineraries.collect{|i| i.errors}
          }
        }
      end
    end
  end

end
