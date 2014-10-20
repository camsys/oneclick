
# Transient class used to aggregate user characteristics so they
# can be updated in a single form.
class UserCharacteristicsProxy < UserProfileProxy

  MIN_YEAR = 1900

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
    characteristic = Characteristic.enabled.active.find_by_code(code)
    unless characteristic.nil?
      map = UserCharacteristic.where(characteristic: characteristic, user_profile: user.user_profile).first
    else #if the code is an accommodation instead of a characteristic
      characteristic = Accommodation.enabled.active.where(code: code).first
      if characteristic.nil?
        return super
      end
      map = UserAccommodation.where(accommodation: characteristic, user_profile: user.user_profile).first
    end

    # if the user has an existing characteristics stored we return it.
    return coerce_value(characteristic, map)
  end

  # Returns a symbol if it needs to be run through I18n or a string if it can be displayed as is
  def get_answer_description(code)
    characteristic = Characteristic.find_by_code(code)
    map = UserCharacteristic.where("characteristic_id = ? AND user_profile_id = ?", characteristic.id, user.user_profile.id).first
    return coerce_value_to_string(characteristic, map)
  end

  def update_maps(new_settings)
    valid = true
    valid &= update_maps_characteristics(new_settings)
    valid &= update_maps_accommodations(new_settings)
    valid
  end

  # Update the user characteristics based on the form params
  def update_maps_characteristics(new_settings)
    Rails.logger.debug "UserCharacteristicsProxy.update_maps()"
    Rails.logger.debug new_settings.inspect

    valid = true
    # Put everything in a big transaction
    UserCharacteristic.transaction do
      # Loop through the list of characteristics that could be set. This appraoch ensures we are only updating
      # active characteristics
      Characteristic.enabled.each do |characteristic|
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

          # Check for date failing to parse or out of range
          this_year = DateTime.now.year

          if characteristic.datatype == 'date' and (new_value != '') and
              (new_value.nil? or (new_value.year < MIN_YEAR) or (new_value.year > this_year))
            errors.add(characteristic.code.to_sym,
                       I18n.t(:four_digit_year) + " #{MIN_YEAR} - #{this_year}")
            valid = false
            next
          end

          update_user_characteristic_value(characteristic.id, user.user_profile.id, new_value)

          #: sync dob -> age
          linked_characteristic = characteristic.linked_characteristic
          if characteristic.datatype == 'date' and (new_value != '') and
            !linked_characteristic.nil? and linked_characteristic.code == 'age'
            new_age = this_year - new_value.year
            new_age -= 1 if DateTime.now < new_value + new_age.years
            update_user_characteristic_value(linked_characteristic.id, user.user_profile.id, new_age)
          end
        end
      end

    end
    valid
  end

  def update_user_characteristic_value(char_id, user_profile_id, new_value)
    # See if this characteristic already exists in the database for this user
    user_characteristic = UserCharacteristic.where("characteristic_id = ? AND user_profile_id = ?", char_id, user_profile_id).first
    if user_characteristic
      # it does so lets update it.

      # if the value is non null we update otherwise we remove the current setting
      if new_value.blank?
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
      UserCharacteristic.create(:characteristic_id => char_id, :user_profile_id => user_profile_id, :value => new_value) unless new_value.nil?
    end
  end

  # Update the user accommodation based on the form params
  def update_maps_accommodations(new_settings)

    Rails.logger.debug "UserAccommodationsProxy.update_maps()"
    Rails.logger.debug new_settings.inspect


    # Put everything in a big transaction
    UserAccommodation.transaction do

      # Loop through the list of accommodation that could be set. This appraoch ensures we are only updating
      # active accommodation
      Accommodation.all.each do |accommodation|

        Rails.logger.debug accommodation.inspect

        # See if this accommodation is represented in the new settings. We want to try to match the accommodation code to
        # one or more params. This is needed for date fields which are split over 3 params {day, month year}
        params = new_settings.select {|k, _| k.include? accommodation.code}
        if params.count > 0

          # We found a value for this accommodation in the params
          Rails.logger.debug "Found! " + params.inspect

          # get the new value for this accommodation based on the data type
          new_value = convert_value(accommodation, params)

          Rails.logger.debug new_value.nil? ? "NULL" : new_value

          # See if this accommodation already exists in the database for this user
          user_accommodation = UserAccommodation.where("accommodation_id = ? AND user_profile_id = ?", accommodation.id, user.user_profile.id).first
          if user_accommodation
            # it does so lets update it.

            # if the value is non null we update otherwise we remove the current setting
            if new_value.nil?
              Rails.logger.debug "Removing existing accommodation"
              user_accommodation.destroy
            else
              Rails.logger.debug "Updating existing accommodation"
              user_accommodation.value = new_value
              user_accommodation.save
            end
          else
            # we need to create a new one
            Rails.logger.debug "Creating new accommodation"
            UserAccommodation.create(:accommodation_id => accommodation.id, :user_profile_id => user.user_profile.id, :value => new_value) unless new_value.nil?
          end
        end
      end

    end
    true
  end

end
