class AccommodationsController < TravelerAwareController

  def update

    # set the @traveler variable
    get_traveler

    @user_accommodations_proxy = UserAccommodationsProxy.new(User.find(params[:user_id]))
    @user_accommodations_proxy.update_maps(params[:user_accommodations_proxy])
    flash[:notice] = "Traveler accommodations preferences successfully updated."

    if session[:current_trip_id]
      @planned_trip = PlannedTrip.find(session[:current_trip_id])
      @planned_trip.create_itineraries
      @path = user_planned_trip_path(@traveler, @planned_trip)
      session[:current_trip_id] =  nil
    end

    respond_to do |format|
      format.html { redirect_to @path }
      format.js { render "accommodations/update_form" }

    end
  end

  def new

    @user_accommodations_proxy = UserAccommodationsProxy.new(@traveler)

    respond_to do |format|
      format.html
    end
  end
end
