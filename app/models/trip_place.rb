class TripPlace < ActiveRecord::Base

  TYPES = [
    "Point of Interest",
    "Place",
    "Street Address"
  ]
  # Associations
  belongs_to :trip    # everyone trip place must belong to a trip
  belongs_to :place   # optional
  belongs_to :poi     # optional
  
  # Updatable attributes
  attr_accessible :sequence, :raw_address, :lat, :lon
  
  # set the default scope
  default_scope order('sequence ASC')
  
  def location
    return [poi.lat, poi.lon] unless poi.nil?
    return [place.lat, place.lon] unless place.nil?
    return [lat, lon]
  end
  
  def type
    return TYPES[0] unless poi.nil?
    return TYPES[1] unless place.nil?
    return TYPES[2]
  end
  
  def to_s
    if poi
      return poi.to_s
    elsif place
      return place.to_s
    else
      return raw_address
    end
  end
  
  def geocode
    return if raw_address.blank?
    # result = Geocoder.search(self.nongeocoded_address).as_json
    results = Geocoder.search(self.raw_address, sensor: false, components: Rails.application.config.geocoder_components, bounds: Rails.application.config.geocoder_bounds)
    if addr = results.first
      self.lat      = addr.coordinates.first
      self.lon      = addr.coordinates.last
    end
    self
  end
  
  def geocode!
    self.geocode
  end

  def geocoded?
    if !(self.lat && self.lon)
      # TODO Check this, I think it adds new errors every time it gets called.
      errors.add(:raw_address, I18n.translate(:raw_address))
      return false
    end
    true
  end
  
end
