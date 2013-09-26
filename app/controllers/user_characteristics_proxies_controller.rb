class UserCharacteristicsProxiesController < ApplicationController

  def update

    @user_characteristics_proxy = UserCharacteristicsProxy.new(User.find(params[:user_id]))
    
    if @user_characteristics_proxy.valid?
      @user_characteristics_proxy.update_maps(params[:user_characteristics_proxy])
      @user_characteristics_proxy.update_dob
      flash[:notice] = "Traveler characteristics successfully updated."
    end


    respond_to do |format|
      format.js {render "eligibility/update_eligibility_form"}
    end
  end
end
