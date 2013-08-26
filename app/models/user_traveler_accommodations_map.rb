class UserTravelerAccommodationsMap < ActiveRecord::Base

  #associations
  belongs_to :user_profile
  belongs_to :traveler_accommodation, :class_name => "TravelerAccommodation", :foreign_key => "accommodation_id"

  attr_accessible :user_profile_id, :accommodation_id, :value

end
