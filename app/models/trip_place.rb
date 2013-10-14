class TripPlace < GeocodedAddress
  
  TYPES = [
    "Poi",
    "Place",
    "Street Address"
  ]
  # Associations
  belongs_to :trip    # everyone trip place must belong to a trip
  belongs_to :place   # optional
  belongs_to :poi     # optional
  
  # Updatable attributes
  attr_accessible :sequence, :raw_address
  attr_accessor :raw
  
  # set the default scope
  default_scope order('sequence ASC')
  
  # discover the location for this trip place from
  # its relationships
  def location
    return poi.location unless poi.nil?
    return place.location unless place.nil?
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
    Rails.logger.info "TripPlace writing to cache with TripPlace.raw.#{id}"
    Rails.cache.write("TripPlace.raw.#{id}", raw, :expires_in => Rails.application.config.address_cache_expire_seconds)
  end

  def restore_georaw
    Rails.logger.info "TripPlace reading from cache with TripPlace.raw.#{id}"
    self.raw = Rails.cache.read("TripPlace.raw.#{id}")
    Rails.logger.info "Got #{self.raw}"
  end

end
