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
    accommodation = TravelerAccommodation.find_by_code(code)
    if accommodation.nil?
      return super      
    end
        
    map = UserTravelerAccommodationsMap.where("accommodation_id = ? AND user_profile_id = ?", accommodation.id, user.user_profile.id).first
    # if the user has an existing accommodation stored we return it.
    return coerce_value(accommodation, map)

  end

  # Update the user accommodation based on the form params
  def update_maps(new_settings)
    
    Rails.logger.info "UserAccommodationsProxy.update_maps()"
    Rails.logger.info new_settings.inspect
    
    
    # Put everything in a big transaction
    UserTravelerAccommodationsMap.transaction do
      
      # Loop through the list of accomodation that could be set. This appraoch ensures we are only updating
      # active accomodation
      TravelerAccommodation.all.each do |accomodation|
        
        Rails.logger.info accomodation.inspect
        
        # See if this accomodation is represented in the new settings. We want to try to match the accomodation code to
        # one or more params. This is needed for date fields which are split over 3 params {day, month year}
        params = new_settings.select {|k, _| k.include? accomodation.code}
        if params.count > 0
          
          # We found a value for this accomodation in the params
          Rails.logger.info "Found! " + params.inspect
            
          # get the new value for this accomodation based on the data type
          new_value = convert_value(accomodation, params)
          
          Rails.logger.info new_value.nil? ? "NULL" : new_value
          
          # See if this accomodation already exists in the database for this user
          user_accomodation = UserTravelerAccommodationsMap.where("accommodation_id = ? AND user_profile_id = ?", accomodation.id, user.user_profile.id).first
          if user_accomodation
            # it does so lets update it. 
            
            # if the value is non null we update otherwise we remove the current setting
            if new_value.nil?
              Rails.logger.info "Removing existing accomodation"
              user_accomodation.destroy
            else
              Rails.logger.info "Updating existing accomodation"
              user_accomodation.value = new_value
              user_accomodation.save
            end
          else
            # we need to create a new one
            Rails.logger.info "Creating new accomodation"
            UserTravelerAccommodationsMap.create(:accomodation_id => accomodation.id, :user_profile_id => user.user_profile.id, :value => new_value) unless new_value.nil?
          end
        end
      end
      
    end    
  end

end
