class UserTravelerAccommodationsMap < ActiveRecord::Base

  #associations
  belongs_to :traveler, :class_name => 'User'
  belongs_to :traveler_accommodation
  # attr_accessible :title, :body
end
