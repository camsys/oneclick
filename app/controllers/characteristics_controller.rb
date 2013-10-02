class CharacteristicsController < TravelerAwareController

  def update

    # set the @traveler variable
    get_traveler

    @user_characteristics_proxy = UserCharacteristicsProxy.new(User.find(params[:user_id]))
    @user_characteristics_proxy.update_maps(params[:user_characteristics_proxy])

    @path = new_user_accommodation_path(@traveler)

    #if we are in the 'wizard' don't flash a notice
    unless session[:current_trip_id]
      flash[:notice] = "Traveler characteristics successfully updated."
    end

    respond_to do |format|
      format.html { redirect_to @path }
      format.js { render "characteristics/update_form" }

    end
  end

  def new

    @user_characteristics_proxy = UserCharacteristicsProxy.new(@traveler)

    respond_to do |format|
      format.html
    end
  end

  def skip

    get_traveler

    @planned_trip = PlannedTrip.find(session[:current_trip_id])
    @planned_trip.create_itineraries
    @path = user_planned_trip_path(@traveler, @planned_trip)
    session[:current_trip_id] =  nil

    respond_to do |format|
      format.html { redirect_to @path }
    end
  end

end
