class UserProfile < ActiveRecord::Base
  
  # Associations
  belongs_to :user
  has_many :user_traveler_characteristics_maps
  has_many :user_traveler_accommodations_maps

  has_many :traveler_accommodations, through: :user_traveler_accommodations_maps, source: :traveler_accommodation
  has_many :traveler_characteristics, through: :user_traveler_characteristics_maps, source: :traveler_characteristic

end

