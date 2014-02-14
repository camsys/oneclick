class UserProfile < ActiveRecord::Base
  
  # Associations
  belongs_to :user
  has_many :user_traveler_characteristics_maps
  has_many :user_traveler_accommodations_maps

  has_many :accommodations, through: :user_traveler_accommodations_maps, source: :accommodation
  has_many :characteristics, through: :user_traveler_characteristics_maps, source: :characteristic

  def has_characteristics?
    if self.characteristics.count > 0
      true
    else
      false
    end
  end

end

