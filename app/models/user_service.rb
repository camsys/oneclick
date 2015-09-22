class UserService < ActiveRecord::Base

  #Mapping between services and users.  Used for automated booking.

  #associations
  belongs_to :user_profile
  belongs_to :service

  #disabled
  #external_user_id
  #customer_id  //Temporary customer id used by Ecolane

  def get_booking_trip_purposes
    bs = BookingServices.new
    return bs.get_purposes self
  end

  def get_passenger_types
    bs = BookingServices.new
    return bs.get_passenger_types self
  end


  def get_space_types
    bs = BookingServices.new
    return bs.get_space_types self
  end

end
