class AccommodationsController < TravelerAwareController
  include CsHelpers

  def update

    # set the @traveler variable
    get_traveler

    @user_accommodations_proxy = UserAccommodationsProxy.new(User.find(params[:user_id]))
    @user_accommodations_proxy.update_maps(params[:user_accommodations_proxy])

    if ui_mode_kiosk?
      @path = skip_user_trip_path(@traveler, session[:current_trip_id])
    else
      @path = new_user_registration_path(inline: 1)
    end

    #If we are editing eligbility inline, and we are signed in, do not go to the new_user_registrations_page.
    # Create the itineraries
    if params['inline'] == '1' and user_signed_in?
      @trip = Trip.find(session[:current_trip_id])
      session[:current_trip_id] =  nil
      @trip.create_itineraries
      @path = user_trip_path_for_ui_mode(@traveler, @trip)
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

    get_traveler
    @trip_id = session[:current_trip_id]

    respond_to do |format|
      format.html
    end
  end


end
