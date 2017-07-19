class Service < ActiveRecord::Base
  require 'zip'
  require 'rgeo/shapefile'
  include Rateable # mixin to handle all rating methods
  include Commentable
  include DisableCommented

  validates :display_color, :hexadecimal_color => true

  resourcify

  #Serialize
  serialize :county_endpoint_array #Optionaly use county names as endpoints instead of geometry # DEPRECATED
  serialize :county_coverage_array #Optionaly use county names as coverage area instead of geometry # DEPRECATED

  #associations
  belongs_to :provider
  belongs_to :service_type
  belongs_to :mode
  has_many :fare_structures, :dependent => :destroy
  has_many :schedules, -> { order(day_of_week: :asc) }, :dependent => :destroy
  has_many :booking_cut_off_times, :dependent => :destroy
  has_many :service_accommodations, :dependent => :destroy
  has_many :service_characteristics, :dependent => :destroy
  has_many :service_trip_purpose_maps, :dependent => :destroy
  has_many :service_coverage_maps # DEPRECATED
  has_many :itineraries
  has_many :user_services, :dependent => :destroy
  has_and_belongs_to_many :users # primarily for internal contact
  has_many :fare_zones
  has_many :funding_sources
  has_many :sponsors
  has_one  :ecolane_profile, :dependent => :destroy
  has_one :trapeze_profile, :dependent => :destroy
  has_one :ridepilot_profile, :dependent => :destroy

  accepts_nested_attributes_for :schedules, allow_destroy: true,
  reject_if: proc { |attributes| attributes['start_time'].blank? && attributes['end_time'].blank? }

  accepts_nested_attributes_for :booking_cut_off_times, allow_destroy: true,
  reject_if: proc { |attributes| attributes['cut_off_time'].blank? }

  accepts_nested_attributes_for :service_characteristics, allow_destroy: true,
  reject_if: proc { |attributes| attributes['active'] != 'true' }

  accepts_nested_attributes_for :fare_structures

  accepts_nested_attributes_for :fare_zones

  # accepts_nested_attributes_for :service_coverage_maps, allow_destroy: true, # DEPRECATED
  # reject_if: :check_reject_for_service_coverage_map # Also used to control record destruction. # DEPRECATED

  # attr_accessible :id, :name, :provider, :provider_id, :service_type, :advanced_notice_minutes, :external_id, :active
  # attr_accessible :contact, :contact_title, :phone, :url, :email
  # attr_accessible: booking_service_code

  has_many :accommodations, through: :service_accommodations, source: :accommodation
  has_many :characteristics, through: :service_characteristics, source: :characteristic
  has_many :trip_purposes, through: :service_trip_purpose_maps, source: :trip_purpose
  has_many :coverage_areas, through: :service_coverage_maps, source: :geo_coverage # DEPRECATED

  # New Coverage Area Models
  belongs_to :primary_coverage, class_name: "CoverageZone"
  belongs_to :secondary_coverage, class_name: "CoverageZone"

  has_many :endpoints, -> { where rule: 'endpoint_area' }, class_name: "ServiceCoverageMap" # DEPRECATED

  has_many :coverages, -> { where rule: 'coverage_area' }, class_name: "ServiceCoverageMap" # DEPRECATED

  belongs_to :endpoint_area_geom, class_name: 'GeoCoverage' # DEPRECATED
  belongs_to :coverage_area_geom, class_name: 'GeoCoverage' # DEPRECATED
  belongs_to :residence_area_geom, class_name: 'GeoCoverage' # DEPRECATED

  has_many :user_profiles, through: :user_services, source: :user_profile

  scope :active, -> {where(active: true)}
  scope :ride_hailing, ->  {joins(:service_type).where(service_types: {code: ['uber_x']}) }
  scope :paratransit, -> {joins(:service_type).where(service_types: {code: ["paratransit", "volunteer", "nemt", "tap", "dial_a_ride"] }).order('external_id')}
  #scope :bookable, -> {where.not(booking_service_code: nil).where.not(booking_service_code: '')}
  scope :bookable, -> {where.not(booking_profile: nil)}

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

  def is_demand_responsive?
    service_type && (service_type.code.in? ["paratransit", "volunteer", "nemt", "tap", "dial_a_ride"])
  end


  def is_ride_hailing?
    service_type && ['uber_x'].index(service_type.code)
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

  # # DEPRECATED
  # def save_new_coverage_area_from_shp(rule, geom)
  #   gc = GeoCoverage.create! coverage_type: rule, geom: geom
  #   case rule
  #   when 'endpoint_area'
  #     self.endpoint_area_geom = gc
  #   when 'coverage_area'
  #     self.coverage_area_geom = gc
  #   end
  #   self.save!
  # end

  # # DEPRECATED
  # def update_coverage_map(rule)
  #   scms = self.service_coverage_maps.where(rule: rule)
  #   scms.each do |scm|
  #     polygon = polygon_from_attribute(scm)
  #     if polygon.nil?
  #       next
  #     end
  #     #Rails.logger.info "polygon is #{polygon.ai}"
  #     case rule
  #     when 'endpoint_area'
  #       #Rails.logger.info  "Updating Endpoint Area"
  #       if self.endpoint_area_geom
  #         merged = self.endpoint_area_geom.geom.union(polygon)
  #         if merged.nil?
  #           next
  #         end
  #         self.endpoint_area_geom.geom = RGeo::Feature.cast(merged, :type => RGeo::Feature::MultiPolygon)
  #         self.endpoint_area_geom.save!
  #       else
  #         gc = GeoCoverage.create! coverage_type: 'endpoint_area', geom: polygon
  #         self.endpoint_area_geom = gc
  #         self.save!
  #       end
  #     when 'coverage_area'
  #       #Rails.logger.info  "Updating Coverage Area"
  #       if self.coverage_area_geom
  #         merged = self.coverage_area_geom.geom.union(polygon)
  #         if merged.nil?
  #           next
  #         end
  #         self.coverage_area_geom.geom = RGeo::Feature.cast(merged, :type => RGeo::Feature::MultiPolygon)
  #         self.coverage_area_geom.save!
  #       else
  #         gc = GeoCoverage.create! coverage_type: 'coverage_area', geom: polygon
  #         self.coverage_area_geom = gc
  #         self.save!
  #       end
  #     end
  #   end
  #   self.save!
  # end

  # # DEPRECATED
  # def build_polygons(temp_endpoints_shapefile_path = nil, temp_coverages_shapefile_path = nil)
  #
  #   #endpoint area
  #   endpoint_rule = 'endpoint_area'
  #   endpoint_area_geom = get_shapefile_first_geometry(temp_endpoints_shapefile_path)
  #   unless endpoint_area_geom.nil?
  #     self.service_coverage_maps.where(rule: endpoint_rule).destroy_all
  #     save_new_coverage_area_from_shp(endpoint_rule, endpoint_area_geom)
  #   else
  #     unless temp_endpoints_shapefile_path.nil?
  #       alert_msg = TranslationEngine.translate_text(:no_polygon_geometry_parsed).to_s.sub '%{area_type}', TranslationEngine.translate_text(endpoint_rule).to_s
  #     end
  #     if self.service_coverage_maps.where(rule: endpoint_rule).count > 0
  #       self.endpoint_area_geom = nil
  #     end
  #     update_coverage_map(endpoint_rule)
  #   end
  #
  #   #coverage area
  #   coverage_rule = 'coverage_area'
  #   coverage_area_geom = get_shapefile_first_geometry(temp_coverages_shapefile_path)
  #   unless coverage_area_geom.nil?
  #     self.service_coverage_maps.where(rule: coverage_rule).destroy_all
  #     save_new_coverage_area_from_shp(coverage_rule, coverage_area_geom)
  #   else
  #     unless temp_coverages_shapefile_path.nil?
  #       alert_msg = TranslationEngine.translate_text(:no_polygon_geometry_parsed).to_s.sub '%{area_type}', TranslationEngine.translate_text(coverage_rule).to_s
  #     end
  #     if self.service_coverage_maps.where(rule: coverage_rule).count > 0
  #       self.coverage_area_geom = nil
  #     end
  #     update_coverage_map(coverage_rule)
  #   end
  #
  #   alert_msg
  # end

  # # DEPRECATED
  # # Returns the service area polylines for use in map display_color
  # def get_polylines
  #   polylines = []
  #
  #   ['coverage_area', 'endpoint_area'].each do |rule|
  #     case rule
  #       when 'coverage_area'
  #         geometry = self.coverage_area_geom.try(:geom)
  #         color = 'red'
  #         id = 1
  #       when 'endpoint_area'
  #         geometry = self.endpoint_area_geom.try(:geom)
  #         color = 'green'
  #         id = 0
  #     end
  #
  #     unless geometry.nil?
  #       polylines << {
  #          "id" => id,
  #          "geom" => self.wkt_to_array(rule),
  #          "options" =>  {"color" => color, "width" => "2"}
  #       }
  #     end
  #   end
  #
  #   polylines.to_json || nil
  # end

  # # DEPRECATED
  # def polygon_from_attribute scm
  #   #RGeo::Feature.cast(merged, :type => york.geom.geometry_type)
  #   state = Oneclick::Application.config.state
  #   case scm.geo_coverage.coverage_type
  #     when 'county_name'
  #       county = County.where("lower(name) =? AND state=?", scm.geo_coverage.value.downcase, state)
  #       if county.length > 0
  #         return county.first.geom
  #       end
  #     when 'zipcode'
  #       zipcode = Zipcode.where(zipcode: scm.geo_coverage.value, state: state)
  #       if zipcode.length > 0
  #         return zipcode.first.geom
  #       end
  #     when 'city'
  #       city = City.where("lower(name) =? AND state=?", scm.geo_coverage.value.downcase, state)
  #       if city.length > 0
  #         return city.first.geom
  #       end
  #     when 'polygon'
  #       return scm.geo_coverage.geom
  #   end
  #   nil
  # end

  # # DEPRECATED
  # def destroy_endpoint_geom
  #   endpoint_area_geom.destroy if endpoint_area_geom
  #   endpoint_area_geom = nil
  # end

  # # DEPRECATED
  # def destroy_coverage_geom
  #   coverage_area_geom.destroy if coverage_area_geom
  #   coverage_area_geom = nil
  # end

  # # DEPRECATED
  # def wkt_to_array(rule = 'endpoint_area')
  #   myArray = []
  #   case rule
  #     when 'endpoint_area'
  #       geometry = self.endpoint_area_geom
  #     when 'coverage_area'
  #       geometry = self.coverage_area_geom
  #   end
  #   if geometry
  #     geometry.geom.each do |polygon|
  #       polygon_array = []
  #       ring_array  = []
  #       polygon.exterior_ring.points.each do |point|
  #         ring_array << [point.y, point.x]
  #       end
  #       polygon_array << ring_array
  #
  #       polygon.interior_rings.each do |ring|
  #         ring_array = []
  #         ring.points.each do |point|
  #           ring_array << [point.y, point.x]
  #         end
  #         polygon_array << ring_array
  #       end
  #       myArray << polygon_array
  #     end
  #   end
  #   myArray
  # end

  # csv
  ransacker :id do
    Arel.sql(
      "regexp_replace(
        to_char(\"#{table_name}\".\"id\", '9999999'), ' ', '', 'g')"
    )
  end

  def self.csv_headers
    [
      TranslationEngine.translate_text(:id),
      TranslationEngine.translate_text(:name),
      TranslationEngine.translate_text(:provider),
      TranslationEngine.translate_text(:phone),
      TranslationEngine.translate_text(:email),
      TranslationEngine.translate_text(:service_id),
      TranslationEngine.translate_text(:status)
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
      active ? '' : TranslationEngine.translate_text(:inactive)
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

  # Returns true if passed trip part origin and destination meet primary and secondary coverage tests
  def is_valid_for_trip_area(trip_part)
    origin_lat, origin_lon = trip_part.from_trip_place.lat.to_f, trip_part.from_trip_place.lon.to_f
    destination_lat, destination_lon = trip_part.to_trip_place.lat.to_f, trip_part.to_trip_place.lon.to_f

    # Origin OR destination must lie within PRIMARY coverage
    primary_coverage_test =
      primary_coverage.nil? ||
      primary_coverage.geom.nil? ||
      primary_coverage_contains?(origin_lat, origin_lon) ||
      primary_coverage_contains?(destination_lat, destination_lon)

    # Origin AND destination must lie within SECONDARY coverage
    secondary_coverage_test =
      secondary_coverage.nil? ||
      secondary_coverage.geom.nil? ||
      ( secondary_coverage_contains?(origin_lat, origin_lon) &&
        secondary_coverage_contains?(destination_lat, destination_lon) )

    primary_coverage_test && secondary_coverage_test
  end

  # Returns whether or not trip part falls within service schedule times
  def is_valid_for_trip_schedule(trip_part)
    return true if self.schedules.nil? || self.schedules.empty? # Treat empty schedules as 24/7
    trip_wday = trip_part.trip_time.wday
    trip_time = trip_part.trip_time.seconds_since_midnight
    scheds = self.schedules.where(day_of_week: trip_wday)
    scheds.any? { |s| trip_time.between?(s.start_seconds,s.end_seconds) }
  end

  def can_provide_user_accommodations(user, service)

    user_accommodations_unmet_by_selected_service = UserAccommodation.where("user_profile_id = ? AND value = 'true' AND accommodation_id NOT IN (SELECT accommodation_id from service_accommodations where service_id = ?)", user.user_profile.id, service.id)

    return user_accommodations_unmet_by_selected_service.count == 0

  end

  # Returns true if passed lat, lng are within the service's primary coverage area
  def primary_coverage_contains?(lat, lng)
    primary_coverage && primary_coverage.contains?(lat, lng)
  end

  # Returns true if passed lat, lng are within the service's secondary coverage area
  def secondary_coverage_contains?(lat, lng)
    secondary_coverage && secondary_coverage.contains?(lat, lng)
  end

  # # DEPRECATED
  # def endpoint_contains?(lat,lng)
  #   mercator_factory = RGeo::Geographic.simple_mercator_factory
  #    test_point = mercator_factory.point(lng, lat)
  #   unless self.endpoint_area_geom.nil?
  #     return false unless self.endpoint_area_geom.geom.contains? test_point
  #   end
  #   return true
  # end
  #
  # # DEPRECATED
  # def county_endpoint_contains? county
  #   #Match Endpoint County Names
  #   unless self.county_endpoint_array.blank?
  #     unless county.in? self.county_endpoint_array
  #       return false
  #     end
  #   end
  #
  #   return true
  #
  # end

  # # DEPRECATED
  # def coverage_area_contains?(lat, lng)
  #
  #   mercator_factory = RGeo::Geographic.simple_mercator_factory
  #   test_point = mercator_factory.point(lng, lat)
  #   unless self.coverage_area_geom.nil?
  #     return false unless self.coverage_area_geom.geom.contains? test_point
  #   end
  #   return true
  # end

  # DEPRECATED
  def disallowed_purposes_array
    return self.disallowed_purposes.nil? ? [] : self.disallowed_purposes.split(',')
  end

  #################################
  # BOOKING-SPECIFIC METHODS
  #################################

  def associate_user(user, external_user_id, external_user_password)
    bs = BookingServices.new
    result, user_profile = bs.associate_user(self, user, external_user_id, external_user_password)
    return result
  end

  def is_associated_with_user? user
    #return false if the UserService is missing or is no longer valid
    bs = BookingServices.new
    bs.check_association(self, user)
  end

  def is_bookable?
    unless self.booking_profile.nil?
      return true
    else
      return false
    end
  end

  # # DEPRECATED - NOW IN CoverageZone
  # # Parses a coverage area "recipe" string into an array of matching County, Zipcode, and City objects
  # def parse_coverage_recipe(recipe)
  #   parsed_recipe = recipe.split(',').map(&:strip)
  #
  #   # Create a hash with an array of matches for each area name.
  #   matched_areas = parsed_recipe.each_with_object({}) do |area_recipe, match_hash|
  #
  #     # Look for any bracketed specifiers in the recipe string, and if they exist separate them out
  #     area_recipe = area_recipe.split(/[\[\]]/)
  #     area_name = area_recipe.first.strip.titleize
  #     specifiers = area_recipe.length > 1 ? area_recipe[1].split('-') : []
  #     type_specifier = specifiers.length > 0 ? specifiers[0].strip.titleize : nil
  #     state_specifier = specifiers.length > 1 ? specifiers[1].strip.upcase : nil
  #
  #     # Set the search tables and state filter based on specifiers if they exist, or on config variables if not
  #     search_tables = type_specifier ? [type_specifier] : Oneclick::Application.config.coverage_area_tables
  #     state_filter = state_specifier ? [state_specifier] : Oneclick::Application.config.states
  #     # state_filter = state_specifier ? [state_specifier] : ["MA", "CT", "VA"]
  #
  #     # Make a hash key for the area name, and fill it with an array of matching objects from the database
  #     match_hash[area_name] = [] unless match_hash.key?(area_name)
  #     search_tables.each do |table|
  #       case table
  #       when "County"
  #         # match_hash[area_name] += County.where(name: area_name, state: state_filter).map {|area| {id: area.id, name: area.name, state: area.state}}
  #         match_hash[area_name] += County.where(name: area_name, state: state_filter)
  #       when "Zipcode"
  #         # match_hash[area_name] += Zipcode.where(zipcode: area_name).map {|area| {id: area.id, zipcode: area.zipcode, name: area.name, state: area.state}}
  #         match_hash[area_name] += Zipcode.where(zipcode: area_name)
  #       when "City"
  #         match_hash[area_name] += City.where(name: area_name, state: state_filter)
  #       end
  #     end
  #   end
  #
  #   # puts matched_areas.ai
  #   return matched_areas
  # end

  # # DEPRECATED - NOW IN CoverageZone
  # # Encodes a hash of matching coverage areas into an unambiguous recipe string
  # def encode_coverage_recipe(matched_areas)
  #   match_list = matched_areas.values.flatten
  #   match_list.map! do |area|
  #     case area.class.name
  #     when "County"
  #       "#{area.name} [#{area.class.name}-#{area.state}]"
  #     when "Zipcode"
  #       "#{area.zipcode} [#{area.class.name}]"
  #     else
  #       "#{area.name} [#{area.class.name}-#{area.state}]"
  #     end
  #   end.join(", ")
  # end

  # # DEPRECATED - NOW IN CoverageZone
  # # Creates a coverage area out of a recipe
  # def build_coverage_area(recipe, coverage_area_type="primary_coverage")
  #   parsed_recipe = self.parse_coverage_recipe(recipe)
  #   geoms = parsed_recipe.values.flatten.map {|obj| obj.geom}
  #   self.update_attribute(coverage_area_type, CoverageZone.new(recipe: self.encode_coverage_recipe(parsed_recipe), geom: geoms.reduce { |combined_area, geom| combined_area.union(geom) }))
  # end

  # Returns the coverage area polygons for display in Leaflet
  def coverage_area_polygons
    polylines = []

    if self.primary_coverage.try(:geom)
      polylines << {
           id: 1,
           geom: self.primary_coverage.to_array,
           options:  {color: 'red', width: 2}
        }
    end

    if self.secondary_coverage.try(:geom)
      polylines << {
           id: 1,
           geom: self.secondary_coverage.to_array,
           options:  {color: 'green', width: 2}
        }
    end

    polylines.to_json || nil
  end

  #### End Booking Methods

  def build_fare_structures_by_mode
    if ServiceType.paratransit_ids.include?(service_type_id)
      fare_structures.build(fare_type: 0) # Paratransit
    elsif ServiceType.taxi_ids.include?(service_type_id)
      fare_structures.build(fare_type: 1) # Taxi
    elsif ServiceType.transit_ids.include?(service_type_id)
      # transit actions
    else
      # other actions
    end
  end

  def setup_default_booking_cut_off_times
    self.booking_cut_off_times = (0..6).map {|dow| BookingCutOffTime.new(day_of_week: dow, cut_off_time: "8:00 PM")}
  end

  def purposes_hash
    self.trip_purposes.collect{ |tp| {name: TranslationEngine.translate_text(tp.name), code: tp.code}}
  end

  def characteristics_hash
    self.characteristics.collect{ |c| {name: TranslationEngine.translate_text(c.name), code: c.code, note: TranslationEngine.translate_text(c.note)}}
  end


  def accommodations_hash
    self.accommodations.collect{ |a| {name: TranslationEngine.translate_text(a.name), code: a.code, note: TranslationEngine.translate_text(a.note)}}
  end

  def schedule_hash
    hash = {}
    self.schedules.order(:day_of_week).each do |s|
      if hash[s.day_string]
        hash[s.day_string][:start] << s.start_string
        hash[s.day_string][:end] << s.end_string
      else
        hash[s.day_string] ={start: [s.start_string], end: [s.end_string]}
      end
    end

    schedule_array  = []
    hash.each do |k,v|
      schedule_array << {day: k, start: v[:start], end: v[:end]}
    end

    return schedule_array

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
      errors.add(:max_advanced_book_days_part, TranslationEngine.translate_text(:advanced_book_day_range_msg))
    end
  end

end
