class AccommodationsController < TravelerAwareController

  def update

    # set the @traveler variable
    get_traveler

    @user_accommodations_proxy = UserAccommodationsProxy.new(User.find(params[:user_id]))
    @user_accommodations_proxy.update_maps(params[:user_accommodations_proxy])

    if session[:current_trip_id]

      @path = new_user_registration_path
    end
    
    # Check to see if it was an ajax request from the user profile page
    if request.xhr?    
      flash[:notice] = t(:profile_updated)
    end

    respond_to do |format|
      format.html { redirect_to @path }
      format.js { render "accommodations/update_form" }
    end

  end

  def new

    @user_accommodations_proxy = UserAccommodationsProxy.new(@traveler)

    if session[:current_trip_id]
      get_traveler
      @planned_trip = PlannedTrip.find(session[:current_trip_id])
    end

    respond_to do |format|
      format.html
    end
  end


end
