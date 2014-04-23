class UserService < ActiveRecord::Base

  #Mapping between services and users.  Used for automated booking.

  #associations
  belongs_to :user_profile
  belongs_to :service

  #disabled
  #external_traveler_id

end
