class Service < ActiveRecord::Base
  resourcify

  #associations
  belongs_to :provider
  belongs_to :service_type
  has_many :fare_structures
  has_many :schedules
  has_many :service_accommodations
  has_many :service_characteristics
  has_many :service_trip_purpose_maps
  has_many :service_coverage_maps
  has_many :itineraries
  has_many :user_services
  has_many :users # primarily for internal contact

  # attr_accessible :id, :name, :provider, :provider_id, :service_type, :advanced_notice_minutes, :external_id, :active
  # attr_accessible :contact, :contact_title, :phone, :url, :email
  # attr_accessible: booking_service_id

  has_many :accommodations, through: :service_accommodations, source: :accommodation
  has_many :characteristics, through: :service_characteristics, source: :characteristic
  has_many :trip_purposes, through: :service_trip_purpose_maps, source: :trip_purpose
  has_many :coverage_areas, through: :service_coverage_maps, source: :geo_coverage
  has_many :user_profiles, through: :user_services, source: :user_profile

  scope :active, -> {where(active: true)}

  include Validations

  before_validation :check_url_protocol

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

  def internal_contact
    users.each do |u|
      if u.has_role? :internal_contact, self
        return u
      end
    end
    nil
  end

  def contact_information
    # TODO
    "To be replaced by Scott's work"
  end

  def internal_contact= user
    former = internal_contact
    if !former.nil? && (user != former)
      former.remove_role :internal_contact, self
    end
    user.add_role :internal_contact, self
  end
  
end
