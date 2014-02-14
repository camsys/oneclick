class UserTravelerCharacteristicsMap < ActiveRecord::Base

  #associations
  belongs_to :user_profile
  belongs_to :characteristic, :class_name => "Characteristic", :foreign_key => "characteristic_id"

  attr_accessible :user_profile_id, :user_profile, :characteristic, :characteristic_id, :value


end
