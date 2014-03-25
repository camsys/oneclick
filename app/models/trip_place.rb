class TripPlace < GeocodedAddress
  include TripsSupport

  TYPES = [
    "Poi",
    "Place",
    "Street Address"
  ]

  validate :validator

  # Associations
  belongs_to :trip    # everyone trip place must belong to a trip
  belongs_to :place   # optional
  belongs_to :poi     # optional
  
  # Updatable attributes
  # attr_accessible :sequence, :raw_address
  attr_accessor :raw
  
  # set the default scope
  default_scope {order('sequence ASC')}

  def from_trip_proxy_place json_string, sequence, manual_entry = '', map_center = ''
    self.sequence = sequence
    j = JSON.parse(json_string) rescue {'type_name' => 'MANUAL_ENTRY'}
    case j['type_name']
    when 'POI_TYPE'
      self.update_attributes(
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
      details = get_places_autocomplete_details(j['id'])
      d = cleanup_google_details(details.body['result'])
      self.update_attributes(
        address1: d['address1'],
        city: d['city'],
        state: d['state'],
        zip: d['zip'],
        county: d['county'],
        lat: d['lat'],
        lon: d['lon'],
        raw_address: j['address'],
        result_types: d['result_types']
        )
    when 'MANUAL_ENTRY'
      result = google_place_search(manual_entry, map_center)
      if result.body['status'] == 'ZERO_RESULTS'
        self.errors.add(:base, "No results for search string")
        return self
      end
      first_result = result.body['predictions'].first
      # TODO Copied from above, should be refactored
      details = get_places_autocomplete_details(first_result['reference'])
      d = cleanup_google_details(details.body['result'])
      self.update_attributes(
        address1: d['address1'],
        city: d['city'],
        state: d['state'],
        zip: d['zip'],
        county: d['county'],
        lat: d['lat'],
        lon: d['lon'],
        raw_address: first_result['description'],
        result_types: d['result_types']
        )
    else
      raise "TripPlace.new_from_trip_proxy_place doesn't know how to handle type '#{j['type_name']}'"
    end
    self
  end

  # discover the location for this trip place from
  # its relationships
  def location
    # TODO Check this
    # return poi.location unless poi.nil?
    # return place.location unless place.nil?
    return get_location
  end
  
  def type
    return TYPES[0] unless poi.nil?
    return TYPES[1] unless place.nil?
    return TYPES[2]
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
    return to_s
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
    if !place.nil? && !raw_address.nil?
      errors.add(:base, 'TripPlace cannot have address if predefined place')
      return
    end
    if !poi.nil? && !raw_address.nil?
      errors.add(:base, 'TripPlace cannot have address if POI')
      return
    end
    if (place.nil? && poi.nil?) && raw_address.nil?
      errors.add(:base, 'TripPlace must have raw address if not predefined place or POI')
      return
    end
  end

end
