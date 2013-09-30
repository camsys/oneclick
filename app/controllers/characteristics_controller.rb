class CharacteristicsController < TravelerAwareController

  def update

    @user_characteristics_proxy = UserCharacteristicsProxy.new(User.find(params[:user_id]))
    @user_characteristics_proxy.update_maps(params[:user_characteristics_proxy])
    flash[:notice] = "Traveler characteristics successfully updated."

    respond_to do |format|
      format.js {render "characteristics/update_characteristics_form" }

    end
  end

  def new

    @user_characteristics_proxy = UserCharacteristicsProxy.new(@traveler)

    #Add dob
    #dob_characteristic = TravelerCharacteristic.find_by_code('date_of_birth')
    #UserTravelerCharacteristicsMap.where(characteristic_id: dob_characteristic.id, user_profile_id: @user_characteristics_proxy.user.user_profile.id).first

    respond_to do |format|
      format.html
    end
  end
end
