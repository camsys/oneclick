class Service < ActiveRecord::Base
  include Rateable # mixin to handle all rating methods
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
  has_and_belongs_to_many :users # primarily for internal contact

  accepts_nested_attributes_for :schedules, allow_destroy: true,
  reject_if: proc { |attributes| attributes['start_time'].blank? && attributes['end_time'].blank? }

  accepts_nested_attributes_for :service_characteristics, allow_destroy: true,
  reject_if: proc { |attributes| attributes['active'] != 'true' }

  accepts_nested_attributes_for :fare_structures

  accepts_nested_attributes_for :service_coverage_maps, allow_destroy: true,
  reject_if: :check_reject_for_service_coverage_map # Also used to control record destruction.
  
  # attr_accessible :id, :name, :provider, :provider_id, :service_type, :advanced_notice_minutes, :external_id, :active
  # attr_accessible :contact, :contact_title, :phone, :url, :email
  # attr_accessible: booking_service_code

  has_many :accommodations, through: :service_accommodations, source: :accommodation
  has_many :characteristics, through: :service_characteristics, source: :characteristic
  has_many :trip_purposes, through: :service_trip_purpose_maps, source: :trip_purpose
  has_many :coverage_areas, through: :service_coverage_maps, source: :geo_coverage

  has_many :origins, -> { where rule: 'origin' }, class_name: "ServiceCoverageMap"
  
  has_many :destinations, -> { where rule: 'destination' }, class_name: "ServiceCoverageMap"
    
  has_many :residences, -> { where rule: 'residence' }, class_name: "ServiceCoverageMap"
    
  has_many :user_profiles, through: :user_services, source: :user_profile

  scope :active, -> {where(active: true)}
  scope :paratransit, -> {joins(:service_type).where(service_types: {code: "paratransit"})}

  include Validations

  before_validation :check_url_protocol

  validates :name, presence: true
  validates :provider, presence: true
  validates :service_type, presence: true

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
    users.with_role( :internal_contact, self).first
  end

  def contact_information
    {
      url: url
    }
  end

  def internal_contact= user
    former = internal_contact
    if !former.nil? && (user != former)
      former.remove_role :internal_contact, self
    end
    if !user.nil?
      users << user
      user.add_role :internal_contact, self
      self.save
    end
  end

  def notice_days_part
    advanced_notice_minutes / (60 * 24)
  end
  
  def notice_days_part= value
    update_attributes(advanced_notice_minutes:
                      (value.to_i * (60 * 24)) + (notice_hours_part * 60) + notice_minutes_part)
  end

  def notice_hours_part
    (advanced_notice_minutes / 60) % 24
  end

  def notice_hours_part= value
    update_attributes(advanced_notice_minutes:
      (notice_days_part * (60 * 24)) + (value.to_i * 60) + notice_minutes_part)
  end
  

  def notice_minutes_part
    advanced_notice_minutes % 60
  end

  def notice_minutes_part= value
    update_attributes(advanced_notice_minutes:
      (notice_days_part * (60 * 24)) + (notice_hours_part * 60) + value.to_i)
  end

  # NOTE: also merge destroy attribute for records that exist but not marked keep
  def check_reject_for_service_coverage_map attributes
    keep = attributes['keep_record'].to_s == "1"
    exists = attributes['id'].present?

    if exists && !keep
      attributes.merge!({_destroy: 1})
      return false
    else
      return !keep
    end
  end

  #return an array of the contact info for a service if defined, its provider if not defined at the service, or nil where not answered at either level
  def get_contact_info_array
    rtn = []
    rtn << get_attr(:name)
    rtn << [:provided_by, self.provider.name] # Special case, as the symbol doesn't match the attribute
    rtn << get_attr(:phone)
    rtn << get_attr(:email)
    rtn << get_attr(:url)
  end

  def get_attr(attribute_sym)
    if val = self.send(attribute_sym) #call "phone" for this service.
      return [attribute_sym, val] #return if it exists, else call it on provider
    else
      return self.provider.get_attr(attribute_sym)
    end
  end

  def to_s
    name
  end

  def build_polygons

    #clear old polygons
    self.origin = nil
    self.destination = nil
    self.residence = nil

    ['origin', 'destination', 'residence'].each do |rule|
      scms = self.service_coverage_maps.where(rule: rule)
      scms.each do |scm|
        polygon = polygon_from_attribute(scm)
        if polygon.nil?
          next
        end
        case rule
          when 'origin'
            if self.origin
              merged = self.origin.union(polygon)
              self.origin = RGeo::Feature.cast(merged, :type => RGeo::Feature::MultiPolygon)
              self.save
            else
              self.origin = polygon
              self.save
            end
          when 'destination'
            if self.destination
              merged = self.destination.union(polygon)
              self.destination = RGeo::Feature.cast(merged, :type => RGeo::Feature::MultiPolygon)
              self.save
            else
              self.destination = polygon
              self.save
            end
          when 'residence'
            if self.residence
              merged = self.residence.union(polygon)
              self.residence = RGeo::Feature.cast(merged, :type => RGeo::Feature::MultiPolygon)
              self.save
            else
              self.residence = polygon
              self.save
            end
        end
      end
    end
    self.save

  end

  def polygon_from_attribute scm
    #RGeo::Feature.cast(merged, :type => york.geom.geometry_type)
    state = Oneclick::Application.config.state
    case scm.geo_coverage.coverage_type
      when 'county_name'
        county = County.where("lower(name) =? AND state=?", scm.geo_coverage.value.downcase, state)
        if county.length > 0
          return county.first.geom
        end
      when 'zipcode'
        zipcode = Zipcode.where(zipcode: scm.geo_coverage.value, state: state)
        if zipcode.length > 0
          return zipcode.first.geom
        end
      when 'polygon'
        return scm.geo_coverage.geom
    end
    nil
  end

  def wkt_to_array(rule = 'origin')
    myArray = []
    case rule
      when 'origin'
        geometry = self.origin
      when 'destination'
        geometry = self.destination
      when 'residence'
        geometry = self.residence
    end
    if geometry
      geometry.each do |polygon|
        polygon_array = []
        ring_array  = []
        polygon.exterior_ring.points.each do |point|
          ring_array << [point.y, point.x]
        end
        polygon_array << ring_array

        polygon.interior_rings.each do |ring|
          ring_array = []
          ring.points.each do |point|
            ring_array << [point.y, point.x]
          end
          polygon_array << ring_array
        end
        myArray << polygon_array
      end
    end
    myArray.first
  end


  
end
