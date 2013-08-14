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
    result = Geocoder.search(self.raw_address, sensor: false,
      components: Rails.application.config.geocoder_components,
      bounds: Rails.application.config.geocoder_bounds).as_json
    unless result.length == 0
      self.lat = result[0]['data']['geometry']['location']['lat']
      self.lon = result[0]['data']['geometry']['location']['lng']
      #self.address = result[0]['data']['formatted_address']
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
