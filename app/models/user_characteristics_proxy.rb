
# Transient class used to aggregate user characteristics so they
# can be updated in a single form.
class UserCharacteristicsProxy < UserProfileProxy

  def initialize(user = nil)
    super(user)
  end

  def date_of_birth
    super
  end

  # callback used to derive the value of a user characteristic using a dynamic finder.
  # This method is used to lookup the value of a user characteristics from the database
  # based on the characteristic code which is the name of the attribute being queried on
  # the object.
  def method_missing(code, *args)
    # See if the code exists in the characteristics database
    characteristic = Characteristic.enabled.find_by_code(code)
    if characteristic.nil?
      characteristic = Accommodation.where(code: code).first
      if characteristic.nil?
        return super
      end
    end

    map = UserCharacteristic.where("characteristic_id = ? AND user_profile_id = ?", characteristic.id, user.user_profile.id).first
    unless map
      map = UserAccommodation.where(accommodation: characteristic, user_profile: user.user_profile).first
    end    
    # if the user has an existing characteristics stored we return it.
    return coerce_value(characteristic, map)
  end

  # Update the user characteristics based on the form params
  def update_maps(new_settings)
    Rails.logger.debug "UserCharacteristicsProxy.update_maps()"
    Rails.logger.debug new_settings.inspect

    # Put everything in a big transaction
    UserCharacteristic.transaction do
      # Loop through the list of characteristics that could be set. This appraoch ensures we are only updating
      # active characteristics
      Characteristic.personal_factors.each do |characteristic|
        Rails.logger.debug characteristic.inspect

        # See if this characteristic is represented in the new settings. We want to try to match the characteristic code to
        # one or more params. This is needed for date fields which are split over 3 params {day, month year}
        params = new_settings.select {|k, _| k.include? characteristic.code}
        if params.count > 0
          # We found a value for this characteristic in the params
          Rails.logger.debug "Found! " + params.inspect

          # get the new value for this characteristic based on the data type
          new_value = convert_value(characteristic, params)

          Rails.logger.debug new_value.nil? ? "NULL" : new_value

          # See if this characteristic already exists in the database for this user
          user_characteristic = UserCharacteristic.where("characteristic_id = ? AND user_profile_id = ?", characteristic.id, user.user_profile.id).first
          if user_characteristic
            # it does so lets update it.

            # if the value is non null we update otherwise we remove the current setting
            if new_value.nil?
              Rails.logger.debug "Removing existing characteristic"
              user_characteristic.destroy
            else
              Rails.logger.debug "Updating existing characteristic"
              user_characteristic.value = new_value
              user_characteristic.save!
            end
          else
            # we need to create a new one
            Rails.logger.debug "Creating new characteristic"
            UserCharacteristic.create(:characteristic_id => characteristic.id, :user_profile_id => user.user_profile.id, :value => new_value) unless new_value.nil?
          end
        end
      end

    end

  end

end
