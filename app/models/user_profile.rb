class UserProfile < ActiveRecord::Base
  
  # Associations
  belongs_to :user
  has_many :user_traveler_characteristics_maps
  has_many :user_traveler_accommodations_maps


end

