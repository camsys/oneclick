class CharacteristicsController < TravelerAwareController

  def update

    # set the @traveler variable
    get_traveler

    @user_characteristics_proxy = UserCharacteristicsProxy.new(User.find(params[:user_id]))
    @user_characteristics_proxy.update_maps(params[:user_characteristics_proxy])
    flash[:notice] = "Traveler characteristics successfully updated."

    @path = new_user_accommodation_path(@traveler)

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
end
