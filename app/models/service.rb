class Service < ActiveRecord::Base

  #associations
  belongs_to :provider
  belongs_to :service_type
  has_many :converage_ares
  has_many :fare_structures
  has_many :schedules
  has_many :service_traveler_accommodations_maps
  has_many :service_traveler_characteristics_maps
  has_many :service_trip_purpose_maps

  attr_accessible :id, :name, :provider_id, :service_type_id, :advanced_notice_minutes
end
