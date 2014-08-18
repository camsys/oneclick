class UserService < ActiveRecord::Base

  #Mapping between services and users.  Used for automated booking.

  #associations
  belongs_to :user_profile
  belongs_to :service

  #disabled
  #external_user_id
  #customer_id  //Temporary customer id used by Ecolane

end
