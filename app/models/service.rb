class Service < ActiveRecord::Base

  #associations
  belongs_to :provider
  belongs_to :service_type
  has_many :fare_structures
  has_many :schedules
  has_many :service_traveler_accommodations_maps
  has_many :service_traveler_characteristics_maps
  has_many :service_trip_purpose_maps
  has_many :service_coverage_maps
  has_many :itineraries
  attr_accessible :id, :name, :provider, :provider_id, :service_type, :advanced_notice_minutes, :external_id, :active

  has_many :traveler_accommodations, through: :service_traveler_accommodations_maps, source: :traveler_accommodation
  has_many :traveler_characteristics, through: :service_traveler_characteristics_maps, source: :traveler_characteristic
  has_many :trip_purposes, through: :service_trip_purpose_maps, source: :trip_purpose
  has_many :coverage_areas, through: :service_coverage_maps, source: :geo_coverage

  scope :active, where(active: true)

  def human_readable_advanced_notice
    if self.advanced_notice_minutes < (24*60)
      hours = self.advanced_notice_minutes/60.round
      if hours == 1
        return "1 hour"
      else
        return hours.to_s + " hours"
      end
    else
      days = self.advanced_notice_minutes/(24*60).round
      if days == 1
        return "1 day"
      else
        return days.to_s + " days"
      end
    end
  end

  def full_name
    provider.name.blank? ? name : ("%s, %s" % [name, provider.name])
  end

end
