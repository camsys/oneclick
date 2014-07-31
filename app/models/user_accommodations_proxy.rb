# Transient class used to aggregate user eligibility so they
# can be updated in a single form.
class UserAccommodationsProxy < UserProfileProxy

  def initialize(user = nil)
    super(user)
  end

  # callback used to derive the value of a user accommodation using a dynamic finder.
  # This method is used to lookup the value of a user accommodation from the database
  # based on the accommodation code which is the name of the attribute being queried on
  # the object.
  def method_missing(code, *args)

    # See if the code exists in the accommodation database
    accommodation = Accommodation.find_by_code(code)
    if accommodation.nil?
      return super      
    end
        
    map = UserAccommodation.where("accommodation_id = ? AND user_profile_id = ?", accommodation.id, user.user_profile.id).first
    # if the user has an existing accommodation stored we return it.
    return coerce_value(accommodation, map)

  end

  # Returns a symbol if it needs to be run through I18n or a string if it can be displayed as is
  def get_answer_description(code)
    accommodation = Accommodation.find_by_code(code)
    map = UserAccommodation.where("accommodation_id = ? AND user_profile_id = ?", accommodation.id, user.user_profile.id).first
    # if the user has an existing accommodation stored we return it.
    return coerce_value_to_string(accommodation, map)
  end

  # Update the user accommodation based on the form params
  def update_maps(new_settings)
    
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
