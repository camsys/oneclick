class Characteristic < ActiveRecord::Base

  attr_accessible :id, :code, :name, :note, :datatype, :active, :characteristic_type, :desc

  has_many :user_traveler_characteristics_maps
  has_many :user_profiles, through: :user_traveler_characteristics_maps

  has_many :service_traveler_characteristics_maps
  has_many :services, through: :service_traveler_characteristics_maps

  # set the default scope
  default_scope where('characteristics.active = ?', true)
  scope :personal_factors, where('characteristic_type = ?', 'personal_factor')
  scope :programs, where('characteristic_type = ?', 'program')

end
