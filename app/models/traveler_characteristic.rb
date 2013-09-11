class TravelerCharacteristic < ActiveRecord::Base

  attr_accessible :id, :code, :name, :note, :datatype

  has_many :user_traveler_characteristics_maps
  has_many :user_profiles, through: :user_traveler_characteristics_maps

  has_many :service_traveler_characteristics_maps
  has_many :services, through: :service_traveler_characteristics_maps

end
