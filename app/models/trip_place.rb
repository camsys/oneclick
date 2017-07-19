class TripPlace < GeocodedAddress
  include TripsSupport

  TYPES = [
    "Poi",
    "Place",
    "Street Address"
  ]

  validate :validator
  serialize :types

  # Associations
  belongs_to :trip    # everyone trip place must belong to a trip
  belongs_to :place   # optional
  belongs_to :poi     # optional
  has_one :user, :through => :trip

  # Updatable attributes
  # attr_accessible :sequence, :raw_address
  attr_accessor :raw

  # set the default scope
  default_scope {order('sequence ASC')}

  def from_trip_proxy_place json_string, sequence, manual_entry = '', map_center = '', traveler = nil
    self.sequence = sequence
    j = JSON.parse(json_string) rescue {'type_name' => 'MANUAL_ENTRY'}
    place_type = j['type_name'] || 'MANUAL_ENTRY'

    # pre-process MANUAL_ENTRY to see if any match from Places and POIs
    if place_type == 'MANUAL_ENTRY'
      match_place = traveler.places.active.where(Place.arel_table[:name].matches(manual_entry)).first if traveler
      if match_place
        j = match_place
        place_type = 'PLACES_TYPE'
      else
        match_poi = Poi.where(Poi.arel_table[:name].matches(manual_entry)).first
        if match_poi
          j = match_poi
          place_type = 'POI_TYPE'
        end
      end
    end

    j['county'] = Oneclick::Application.config.default_county if j['county'].blank?
    case place_type
    when 'PLACES_TYPE'
      self.update_attributes(
        place_id: j['id'],
        name: j['name'],
        address1: j['address1'],
        address2: j['address2'],
        city: j['city'],
        state: j['state'],
        zip: j['zip'],
        county: j['county'],
        lat: j['lat'],
        lon: j['lon'],
        raw_address: j['full_address'])
    when 'CACHED_ADDRESS_TYPE'
      self.update_attributes(
        name: j['name'],
        address1: j['address1'],
        address2: j['address2'],
        city: j['city'],
        state: j['state'],
        zip: j['zip'],
        county: j['county'],
        lat: j['lat'],
        lon: j['lon'],
        raw_address: j['raw_address'])
    when 'POI_TYPE'
      self.update_attributes(
        poi_id: j['id'],
        name: j['name'],
        address1: j['address1'],
        address2: j['address2'],
        city: j['city'],
        state: j['state'],
        zip: j['zip'],
        county: j['county'],
        lat: j['lat'],
        lon: j['lon'],
        raw_address: j['full_address'])
    when 'PLACES_AUTOCOMPLETE_TYPE'
      google_result = update_address_attributes_from_google(j['id'], j['reference'], j['address'], j['google_details'])
      if !google_result
        self.errors.add(:base, "No results for search string")
        return self
      end
    when 'MANUAL_ENTRY' # only google_search
      result = google_place_search(manual_entry, map_center)
      if result.body['status'] == 'ZERO_RESULTS'
        self.errors.add(:base, "No results for search string")
        return self
      end
      first_result = result.body['predictions'].first

      google_result = update_address_attributes_from_google(first_result['place_id'], first_result['reference'], first_result['description'])
      if !google_result
        self.errors.add(:base, "No results for search string")
        return self
      end
    else
      raise "TripPlace.new_from_trip_proxy_place doesn't know how to handle type '#{j['type_name']}'"
    end
    self
  end

  def update_address_attributes_from_google(place_id, reference, raw_address, google_details=nil)
    if !google_details
      details = get_places_autocomplete_details(place_id, reference) 
      google_details = details.body['result']
    end

    if google_details
      d = cleanup_google_details(google_details)

      d['county'] = Oneclick::Application.config.default_county if d['county'].blank?
      d['state'] = Oneclick::Application.config.state if d['state'].blank?
      d['address1'] = d['neighborhood'] if d['address1'].blank?
      if d['address1'].blank? && google_details['name'] != d['city']
        d['address1'] = google_details['name']
      end

      self.update_attributes(address1: d['address1'],
                             city: d['city'],
                             state: d['state'],
                             zip: d['zip'],
                             county: d['county'],
                             lat: d['lat'],
                             lon: d['lon'],
                             raw_address: raw_address,
                             result_types: d['result_types'],
                             name: raw_address)
    else
      nil
    end
  end

  #Build a new trip place from PlacesDetails element
  def from_place_details details

    components = details[:address_components]
    unless components.nil?
      components.each do |component|
        types = component[:types]
        if types.nil?
          next
        end
        if 'street_address'.in? types
          self.address1 = component[:long_name]
        elsif 'route'.in? types
          self.route = component[:long_name]
        elsif 'street_number'.in? types
          self.street_number = component[:long_name]
        elsif 'administrative_area_level_1'.in? types
          self.state = component[:long_name]
        elsif 'locality'.in? types
          self.city = component[:long_name]
        elsif 'postal_code'.in? types
          self.zip = component[:long_name]
        elsif 'administrative_area_level_2'.in? types
          self.county = component[:long_name].sub(' County', '')
        end
      end

      #If we didn't get a street address, combine the street number and route into a street address
      if self.address1.nil?
        self.address1 = self.street_number.to_s + ' ' + self.route.to_s
      end

    end

    self.raw_address = details[:formatted_address]
    self.lat = details[:geometry][:location][:lat]
    self.lon = details[:geometry][:location][:lng]
    self.name = details[:name]
    self.google_place_id = details[:place_id]
    self.stop_code = details[:stop_code]
    self.types = details[:types]

    if self.county.blank?
      self.county = get_county
    end

  end

  def get_county
    if self.lat.nil? or self.lon.nil?
      return nil
    end
    oneclick_geocoder = OneclickGeocoder.new
    oneclick_geocoder.get_county(self.lat, self.lon)
  end

  def build_place_details_hash
    #Based on Google Place Details
    {
      address_components: self.address_components,

      formatted_address: self.raw_address,
      place_id: self.google_place_id,
      geometry: {
        location: {
          lat: self.lat,
          lng: self.lon,
        }
      },

      id: self.id,
      name: self.name,
      scope: "user",
      stop_code: self.stop_code,
      types: self.types
    }
  end

  def address_components
    address_components = []

    #street_number
    if self.street_number
      address_components << {long_name: self.street_number, short_name: self.street_number, types: ['street_number']}
    end

    #Route
    if self.route
      address_components << {long_name: self.route, short_name: self.route, types: ['route']}
    end

    #Street Address
    if self.address1
      address_components << {long_name: self.address1, short_name: self.address1, types: ['street_address']}
    end

    #City
    if self.city
      address_components << {long_name: self.city, short_name: self.city, types: ["locality", "political"]}
    end

    #State
    if self.state
      address_components << {long_name: self.zip, short_name: self.zip, types: ["postal_code"]}
    end

    #Zip
    if self.zip
      address_components << {long_name: self.state, short_name: self.state, types: ["administrative_area_level_1","political"]}
    end

    return address_components

  end


  # discover the location for this trip place from
  # its relationships
  def location
    # TODO Check this
    # return poi.location unless poi.nil?
    # return place.location unless place.nil?
    return get_location
  end

  def type_name
    return 'POI_TYPE' unless poi.nil?
    return 'PLACE_TYPE' unless place.nil?
    return 'CACHED_ADDRESS_TYPE'
  end

  # discover the address for this trip place from its
  # relationships
  def address
    return poi.address unless poi.nil?
    return place.address unless place.nil?
    addr = get_address
    return addr.blank? ? raw_address : addr
  end

  def name
    n = read_attribute(:name)
    n.blank? ? to_s : n
  end

  def name2
    n = read_attribute(:name)
    n.blank? ? get_address(2) : n
  end

  def county_name
    return poi.county_name unless poi.nil?
    return place.county_name unless place.nil?
    return get_county_name
  end

  # discover the default string value for this trip place from
  # its relationships
  def to_s
    return poi.to_s unless poi.nil?
    return place.to_s unless place.nil?
    addr = get_address
    return addr.blank? ? raw_address : addr
  end

  # discover the zipcode for this trip place from
  # its relationships
  def zipcode
    return poi.zip unless poi.nil?
    return place.zip unless place.nil?
    return get_zipcode
  end

  def cache_georaw
    Rails.logger.debug "TripPlace writing to cache with TripPlace.raw.#{id}"
    Rails.cache.write("TripPlace.raw.#{id}", raw, :expires_in => Rails.application.config.address_cache_expire_seconds)
  end

  def restore_georaw
    Rails.logger.debug "TripPlace reading from cache with TripPlace.raw.#{id}"
    self.raw = Rails.cache.read("TripPlace.raw.#{id}")
    Rails.logger.debug "Got #{self.raw}"
  end

  private

  def validator
    if !place.nil? && !poi.nil?
      errors.add(:base, 'TripPlace cannot be both place and POI')
      return
    end
    #if !place.nil? && !raw_address.nil?
    #  errors.add(:base, 'TripPlace cannot have address if predefined place')
    #  return
    #end
    #if !poi.nil? && !raw_address.nil?
    #  errors.add(:base, 'TripPlace cannot have address if POI')
    #  return
    #end
    if (place.nil? && poi.nil?) && raw_address.nil?
      errors.add(:base, 'TripPlace must have raw address if not predefined place or POI')
      return
    end
  end

end
