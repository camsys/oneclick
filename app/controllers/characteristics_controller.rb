class CharacteristicsController < TravelerAwareController

  def update

    @user_characteristics_proxy = UserCharacteristicsProxy.new(User.find(params[:user_id]))

    @user_characteristics_proxy.update_maps(params[:user_characteristics_proxy])
    if @user_characteristics_proxy.validate_dob
      @user_characteristics_proxy.update_dob
      flash[:notice] = "Traveler characteristics successfully updated."
    end

    respond_to do |format|
      format.js {render "characteristics/update_characteristics_form" }

    end
  end

  def new

    @user_characteristics_proxy = UserCharacteristicsProxy.new(@traveler)

    #Add dob
    dob_characteristic = TravelerCharacteristic.find_by_code('date_of_birth')
    map = UserTravelerCharacteristicsMap.where(characteristic_id: dob_characteristic.id, user_profile_id: @user_characteristics_proxy.user.user_profile.id).first
    unless map.nil?
      begin
        temp_date = Date.parse(map.value)
      rescue
        @user_characteristics_proxy.dob_day = 'dd'
        @user_characteristics_proxy.dob_month = 'mm'
        @user_characteristics_proxy.dob_year = 'yyyy'
      else
        @user_characteristics_proxy.dob_day = temp_date.day
        @user_characteristics_proxy.dob_month = temp_date.month
        @user_characteristics_proxy.dob_year = temp_date.year
      end
    end

    respond_to do |format|
      format.html
    end
  end
end
