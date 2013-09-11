class Service < ActiveRecord::Base

  #associations
  belongs_to :provider
  belongs_to :service_type
  has_many :coverage_areas
  has_many :fare_structures
  has_many :schedules
  has_many :service_traveler_accommodations_maps
  has_many :service_traveler_characteristics_maps
  has_many :service_trip_purpose_maps
  has_many :itineraries
  attr_accessible :id, :name, :provider_id, :service_type_id, :advanced_notice_minutes


  has_many :traveler_accommodations, through: :service_traveler_accommodations_maps, source: :traveler_accommodation
  has_many :traveler_characteristics, through: :service_traveler_characteristics_maps, source: :traveler_characteristic

end
