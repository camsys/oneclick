class UserCharacteristicsProxiesController < TravelerAwareController

  def create
    
    # Set the @traveler variable
    get_traveler
    # Create a new proxy that will get populated
    @user_characteristics_proxy = UserCharacteristicsProxy.new(@traveler)
    @user_characteristics_proxy.update_maps(params[:user_characteristics_proxy])
    # ensure that everything is copacetic    
    if @user_characteristics_proxy.valid?
      flash[:notice] = "Traveler characteristics successfully updated."
    end
    
    respond_to do |format|
      format.js {render "eligibility/update_eligibility_form"}
    end
  end
end
