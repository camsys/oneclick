class ProgramsController < TravelerAwareController

  before_filter :get_traveler

  def update

    @path = new_user_registration_path(inline: 1)

    @user_programs_proxy = UserProgramsProxy.new(User.find(params[:user_id]))
    @user_programs_proxy.update_maps(params[:user_programs_proxy])

    if params['inline'] == '1'

      if @traveler.has_disability?
        @path = new_user_accommodation_path_for_ui_mode(@traveler, inline: 1)
      else
        if user_signed_in?
          @trip = Trip.find(session[:current_trip_id])          
          session[:current_trip_id] =  nil
          @trip.create_itineraries
          @path = user_trip_path_for_ui_mode(@traveler, @trip)
        else
          @path = skip_user_trip_path_for_ui_mode(@traveler, session[:current_trip_id])
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

    @trip_id = session[:current_trip_id]
    @total_steps = (@traveler.has_disability? ? 3 : 2)
    
    respond_to do |format|
      format.html
    end
  end

end
