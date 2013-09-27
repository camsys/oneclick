class UserAccommodationsProxiesController < TravelerAwareController

  def create

    # Set the @traveler variable
    get_traveler

    @user_accommodations_proxy = UserAccommodationsProxy.new(@traveler)
    @user_accommodations_proxy.update_maps(params[:user_accommodations_proxy])

    flash[:notice] = "Traveler accommodations successfully updated."
    respond_to do |format|
      format.js {render "eligibility/update_accommodations_form"}
    end
  end
end
