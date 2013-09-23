class UserCharacteristicsProxiesController < ApplicationController

  def update

    @user_characteristics_proxy = UserCharacteristicsProxy.new(User.find(params[:user_id]))
    @user_characteristics_proxy.update_maps(params[:user_characteristics_proxy])
    if @user_characteristics_proxy.validate_dob
      @user_characteristics_proxy.update_dob
      flash[:notice] = "Traveler characteristics successfully updated."
    end


    respond_to do |format|
      format.js {render "eligibility/update_eligibility_form"}
    end
  end
end
