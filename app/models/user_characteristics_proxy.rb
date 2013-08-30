class UserTravelerCharacteristicsMap < ActiveRecord::Base

  #associations
  belongs_to :user_profile
  belongs_to :traveler_characteristic, :class_name => "TravelerCharacteristic", :foreign_key => "characteristic_id"

  attr_accessible :user_profile_id, :characteristic_id, :value


end
