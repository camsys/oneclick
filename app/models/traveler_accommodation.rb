class TravelerAccommodation < ActiveRecord::Base
  attr_accessible :id, :code, :name, :note, :datatype

  has_many :user_traveler_accommodations_maps
  has_many :user_profiles, through: :user_traveler_accommodations_maps
end
