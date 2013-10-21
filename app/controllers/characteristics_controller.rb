class CharacteristicsController < TravelerAwareController

  def update

    # set the @traveler variable
    get_traveler

    @user_characteristics_proxy = UserCharacteristicsProxy.new(User.find(params[:user_id]))
    @user_characteristics_proxy.update_maps(params[:user_characteristics_proxy])

    if params['inline'] == '1'
      @path = new_user_accommodation_path(@traveler, inline: 1)
    else
      @path = new_user_accommodation_path(@traveler)
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

    get_traveler
    @planned_trip_id = session[:current_trip_id]

    respond_to do |format|
      format.html
    end
  end

end
