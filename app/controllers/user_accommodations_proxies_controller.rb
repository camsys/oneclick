class UserAccommodationsProxiesController < ApplicationController

  def update

    @user_accommodations_proxy = UserAccommodationsProxy.new(User.find(params[:user_id]))
    @user_accommodations_proxy.update_maps(params[:user_accommodations_proxy])

    flash[:notice] = "Traveler accommodations successfully updated."
    respond_to do |format|
      format.js {render "eligibility/update_eligibility_form"}
    end
  end
end
