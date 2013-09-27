class TravelerCharacteristic < ActiveRecord::Base

  attr_accessible :id, :code, :name, :note, :datatype, :active

  has_many :user_traveler_characteristics_maps
  has_many :user_profiles, through: :user_traveler_characteristics_maps

  has_many :service_traveler_characteristics_maps
  has_many :services, through: :service_traveler_characteristics_maps

  # set the default scope
  default_scope where('traveler_characteristics.active = true')
  
end
