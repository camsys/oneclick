class ProgramsController < TravelerAwareController

  def update

    # set the @traveler variable
    get_traveler

    @path = new_user_registration_path(inline: 1)

    @user_programs_proxy = UserProgramsProxy.new(User.find(params[:user_id]))
    @user_programs_proxy.update_maps(params[:user_programs_proxy])

    if params['inline'] == '1'

      if @traveler.has_disability?
        @path = new_user_accommodation_path(@traveler, inline: 1)
      else
        if user_signed_in?
          @planned_trip = PlannedTrip.find(session[:current_trip_id])
          session[:current_trip_id] =  nil
          @planned_trip.create_itineraries
          @path = user_planned_trip_path(@traveler, @planned_trip)
        else
          @path = new_user_registration_path(inline: 1)
        end
      end
    else
      @path = new_user_program_path(@traveler)
    end

    #if we are in the 'wizard' don't flash a notice. This logic checks to see if
    # the request was an ajax request or not. The trip-planning form does not
    # use ajax.
    if request.xhr?
      flash[:notice] = t(:profile_updated)
    end

    respond_to do |format|
      format.html { redirect_to @path }
      format.js { render "programs/update_form" }

    end
  end

  def new

    @user_programs_proxy = UserProgramsProxy.new(@traveler)

    get_traveler
    @planned_trip_id = session[:current_trip_id]

    respond_to do |format|
      format.html
    end
  end

end
