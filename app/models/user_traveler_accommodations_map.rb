class UserTravelerAccommodationsMap < ActiveRecord::Base

  #associations
  belongs_to :user_profile
  belongs_to :traveler_accommodation, :class_name => "TravelerAccommodation", :foreign_key => "accommodation_id"

  attr_accessible :user_profile_id, :accommodation_id, :value

  validates :user_profile, presence: true
  validates :traveler_accommodation, presence: true
  validates :value, presence: true
  # :verified is required, but defaults in db to false
  # validates :verified, presence: true
end
