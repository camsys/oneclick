class Service < ActiveRecord::Base
  require 'zip'
  require 'rgeo/shapefile'
  include Rateable # mixin to handle all rating methods
  include Commentable

  resourcify

  #associations
  belongs_to :provider
  belongs_to :service_type
  belongs_to :mode
  has_many :fare_structures
  has_many :schedules
  has_many :booking_cut_off_times
  has_many :service_accommodations
  has_many :service_characteristics
  has_many :service_trip_purpose_maps
  has_many :service_coverage_maps
  has_many :itineraries
  has_many :user_services
  has_and_belongs_to_many :users # primarily for internal contact
  has_many :fare_zones

  accepts_nested_attributes_for :schedules, allow_destroy: true,
  reject_if: proc { |attributes| attributes['start_time'].blank? && attributes['end_time'].blank? }

  accepts_nested_attributes_for :booking_cut_off_times, allow_destroy: true,
  reject_if: proc { |attributes| attributes['cut_off_time'].blank? }

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

  has_many :endpoints, -> { where rule: 'endpoint_area' }, class_name: "ServiceCoverageMap"

  has_many :coverages, -> { where rule: 'coverage_area' }, class_name: "ServiceCoverageMap"

  belongs_to :endpoint_area_geom, class_name: 'GeoCoverage'
  belongs_to :coverage_area_geom, class_name: 'GeoCoverage'
  belongs_to :residence_area_geom, class_name: 'GeoCoverage'

  has_many :user_profiles, through: :user_services, source: :user_profile

  scope :active, -> {where(active: true)}
  scope :paratransit, -> {joins(:service_type).where("service_types.code IN (?,?,?)", "paratransit", "volunteer", "nemt")}
  scope :bookable, -> {where.not(booking_service_code: nil).where.not(booking_service_code: '')}

  include Validations

  before_validation :check_url_protocol

  validates :name, presence: true
  validates :provider, presence: true
  validates :service_type, presence: true
  validate :ensure_valid_advanced_book_day_range

  mount_uploader :logo, ServiceLogoUploader

  def is_paratransit?
    is_service_type('paratransit')
  end
  
  def is_transit?
    is_service_type('transit')
  end

  def is_taxi?
    is_service_type('taxi')
  end

  def is_service_type(type)
    service_type && service_type.code == type
  end

  def human_readable_advanced_notice
    human_readable_time_notice(self.advanced_notice_minutes)
  end

  def human_readable_max_allow_advanced_notice
    human_readable_time_notice(self.max_advanced_book_minutes)
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

  def max_advanced_book_days_part
    max_advanced_book_minutes / (60 * 24)
  end

  def max_advanced_book_days_part= value
    update_attributes(max_advanced_book_minutes:
                      (value.to_i * (60 * 24)) + (max_advanced_book_hours_part * 60) + max_advanced_book_minutes_part)
  end

  def max_advanced_book_hours_part
    (max_advanced_book_minutes / 60) % 24
  end

  def max_advanced_book_hours_part= value
    update_attributes(max_advanced_book_minutes:
      (max_advanced_book_days_part * (60 * 24)) + (value.to_i * 60) + max_advanced_book_minutes_part)
  end


  def max_advanced_book_minutes_part
    max_advanced_book_minutes % 60
  end

  def max_advanced_book_minutes_part= value
    update_attributes(max_advanced_book_minutes:
      (max_advanced_book_days_part * (60 * 24)) + (max_advanced_book_hours_part * 60) + value.to_i)
  end

  def self.max_allow_advanced_book_days
    Oneclick::Application.config.service_max_allow_advanced_book_days || 365
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

  def get_shapefile_first_geometry(shapefile_path)
    unless shapefile_path.nil?
      begin
        Zip::File.open(shapefile_path) do |zip_file|
          zip_shp = zip_file.glob('**/*.shp').first
          unless zip_shp.nil?
            zip_shp_paths = zip_shp.name.split('/')
            file_name = zip_shp_paths[zip_shp_paths.length - 1].sub '.shp', ''
            shp_name = nil
            Dir.mktmpdir do |dir|
              shp_name = "#{dir}/" + file_name + '.shp'
              zip_file.each do |entry|
                entry_names = entry.name.split('/')
                entry_name = entry_names[entry_names.length - 1]
                if entry_name.include?(file_name)
                  entry.extract("#{dir}/" + entry_name)
                end
              end

              RGeo::Shapefile::Reader.open(shp_name, { :assume_inner_follows_outer => true }) do |shapefile|
                shapefile.each do |shape|
                  if not shape.geometry.nil? and shape.geometry.geometry_type.to_s.downcase.include?('polygon') #only return first polygon
                    return shape.geometry
                  end
                end
              end
            end
          end
        end
      rescue Exception => msg
        Rails.logger.info 'shapefile parse error'
        Rails.logger.info msg
      end
    end

    return nil
  end

  def save_new_coverage_area_from_shp(rule, geom)
    gc = GeoCoverage.create! coverage_type: rule, geom: geom
    case rule
    when 'endpoint_area'
      self.endpoint_area_geom = gc
    when 'coverage_area'
      self.coverage_area_geom = gc
    end
    self.save!
  end

  def update_coverage_map(rule)
    scms = self.service_coverage_maps.where(rule: rule)
    scms.each do |scm|
      polygon = polygon_from_attribute(scm)
      if polygon.nil?
        next
      end
      #Rails.logger.info "polygon is #{polygon.ai}"
      case rule
      when 'endpoint_area'
        #Rails.logger.info  "Updating Endpoint Area"
        if self.endpoint_area_geom
          merged = self.endpoint_area_geom.geom.union(polygon)
          self.endpoint_area_geom.geom = RGeo::Feature.cast(merged, :type => RGeo::Feature::MultiPolygon)
          self.endpoint_area_geom.save!
        else
          gc = GeoCoverage.create! coverage_type: 'endpoint_area', geom: polygon
          self.endpoint_area_geom = gc
          self.save!
        end
      when 'coverage_area'
        #Rails.logger.info  "Updating Coverage Area"
        if self.coverage_area_geom
          merged = self.coverage_area_geom.geom.union(polygon)
          self.coverage_area_geom.geom = RGeo::Feature.cast(merged, :type => RGeo::Feature::MultiPolygon)
          self.coverage_area_geom.save!
        else
          gc = GeoCoverage.create! coverage_type: 'coverage_area', geom: polygon
          self.coverage_area_geom = gc
          self.save!
        end
      end
    end
    self.save!
  end

  def build_polygons(temp_endpoints_shapefile_path = nil, temp_coverages_shapefile_path = nil)

    #endpoint area
    endpoint_rule = 'endpoint_area'
    endpoint_area_geom = get_shapefile_first_geometry(temp_endpoints_shapefile_path)
    unless endpoint_area_geom.nil?
      self.service_coverage_maps.where(rule: endpoint_rule).destroy_all
      save_new_coverage_area_from_shp(endpoint_rule, endpoint_area_geom)
    else
      unless temp_endpoints_shapefile_path.nil?
        alert_msg = I18n.t(:no_polygon_geometry_parsed).to_s.sub '%{area_type}', I18n.t(endpoint_rule).to_s
      end
      if self.service_coverage_maps.where(rule: endpoint_rule).count > 0
        self.endpoint_area_geom = nil
      end
      update_coverage_map(endpoint_rule)
    end

    #coverage area
    coverage_rule = 'coverage_area'
    coverage_area_geom = get_shapefile_first_geometry(temp_coverages_shapefile_path)
    unless coverage_area_geom.nil?
      self.service_coverage_maps.where(rule: coverage_rule).destroy_all
      save_new_coverage_area_from_shp(coverage_rule, coverage_area_geom)
    else
      unless temp_coverages_shapefile_path.nil?
        alert_msg = I18n.t(:no_polygon_geometry_parsed).to_s.sub '%{area_type}', I18n.t(coverage_rule).to_s
      end
      if self.service_coverage_maps.where(rule: coverage_rule).count > 0
        self.coverage_area_geom = nil
      end
      update_coverage_map(coverage_rule)
    end

    alert_msg
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
      when 'city'
        city = City.where("lower(name) =? AND state=?", scm.geo_coverage.value.downcase, state)
        if city.length > 0
          return city.first.geom
        end
      when 'polygon'
        return scm.geo_coverage.geom
    end
    nil
  end

  def wkt_to_array(rule = 'endpoint_area')
    myArray = []
    case rule
      when 'endpoint_area'
        geometry = self.endpoint_area_geom
      when 'coverage_area'
        geometry = self.coverage_area_geom
    end
    if geometry
      geometry.geom.each do |polygon|
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
    myArray
  end

  # csv
  ransacker :id do
    Arel.sql(
      "regexp_replace(
        to_char(\"#{table_name}\".\"id\", '9999999'), ' ', '', 'g')"
    )
  end

  def self.csv_headers
    [
      I18n.t(:id),
      I18n.t(:name),
      I18n.t(:provider),
      I18n.t(:phone),
      I18n.t(:email),
      I18n.t(:service_id),
      I18n.t(:status)
    ]
  end

  def to_csv
    [
      id,
      name,
      provider.name,
      phone,
      email,
      external_id,
      active ? '' : I18n.t(:inactive)
    ].to_csv
  end

  def self.get_exported(rel, params = {})
    if params[:bIncludeInactive] != 'true'
      rel = rel.where(active: true)
    end

    if !params[:search].blank?
      rel = rel.ransack({
        :id_or_name_or_provider_name_or_phone_or_email_or_external_id_cont => params[:search]
        }).result(:district => true)
    end

    rel
  end

  def is_valid_for_trip_area(from, to)

   #taken from def eligible_by_location(trip_part, itineraries)
   #some day we may want to pass the whole object around and not just from/to
   
   mercator_factory = RGeo::Geographic.simple_mercator_factory

   service = self

   Rails.logger.info "eligible_by_location for service #{service.name rescue nil}"

   origin_point = mercator_factory.point(from[0], from[1])
   destination_point = mercator_factory.point(to[0], to[1])

   # right now we validate a service as eligible for location if the endpoint_area_geom or coverage_area_geom is nil... really?
   return false if service.endpoint_area_geom.nil?
   return false if service.coverage_area_geom.nil?

   return false unless service.endpoint_area_geom.geom.contains? origin_point or service.endpoint_area_geom.geom.contains? destination_point

   return false unless service.coverage_area_geom.geom.contains? origin_point and service.coverage_area_geom.geom.contains? destination_point

   return true

  end

  def can_provide_user_accommodations(user, service)

    user_accommodations_unmet_by_selected_service = UserAccommodation.where("user_profile_id = ? AND value = 'true' AND accommodation_id NOT IN (SELECT accommodation_id from service_accommodations where service_id = ?)", user.user_profile.id, service.id)

    return user_accommodations_unmet_by_selected_service.count == 0

  end

  private

  def human_readable_time_notice(time_in_mins)
    if self.time_in_mins < (24*60)
      hours = self.time_in_mins/60.round
      if hours == 1
        return "1 hour"
      else
        return hours.to_s + " hours"
      end
    else
      days = self.time_in_mins/(24*60).round
      if days == 1
        return "1 day"
      else
        return days.to_s + " days"
      end
    end
  end

  def ensure_valid_advanced_book_day_range
    min_mins = self.advanced_notice_minutes 
    max_mins = self.max_advanced_book_minutes
    if !min_mins.nil? && !max_mins.nil? && min_mins > max_mins
      errors.add(:max_advanced_book_days_part, I18n.t(:advanced_book_day_range_msg))
    end
  end

end
