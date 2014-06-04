class CharacteristicsController < TravelerAwareController
  before_filter :get_traveler

  def update
    @user_characteristics_proxy = UserCharacteristicsProxy.new(User.find(params[:user_id]))
    @user_characteristics_proxy.update_maps(params[:user_characteristics_proxy])

    if params['inline'] == '1' || params[:trip_id]
      @trip = Trip.find(session[:current_trip_id] || params[:trip_id])
      @trip.remove_itineraries
      @path = populate_user_trip_path(@traveler, @trip, {asynch: 1})
      # session[:current_trip_id] =  nil
      # @trip.create_itineraries
      # @path = user_trip_path_for_ui_mode(@traveler, @trip)
    end

    #if we are in the 'wizard' don't flash a notice. This logic checks to see if
    # the request was an ajax request or not. The trip-planning form does not
    # use ajax.
    if request.xhr?
      flash[:notice] = t(:profile_updated)
    end

    respond_to do |format|
      format.html { redirect_to @path }
      format.js { render "characteristics/update_form" }
    end
  end

  def new
    @user_characteristics_proxy = UserCharacteristicsProxy.new(@traveler)

    @trip_id = session[:current_trip_id] || params[:trip_id]
    @trip = Trip.find(@trip_id)
    @total_steps = (@traveler.has_disability? ? 3 : 2)

    respond_to do |format|
      format.html
    end
  end

  # TODO Not used anymore
  def header
    @total_steps = (params[:state] == 'user_characteristics_proxy_disabled_true' ? 3 : 2)
    Rails.logger.info  "total_steps: #{@total_steps}"

    respond_to do |format|
      format.html { render partial: 'header', locals: {total_steps: @total_steps}}
    end
  end
end
