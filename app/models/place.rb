class Place < ActiveRecord::Base

  # associations
  belongs_to :user  
  belongs_to :creator, :class_name => "User", :foreign_key => "creator_id"
  belongs_to :poi       # optional
  has_many :trip_places # optional
  
  attr_accessible :name, :address1, :address2, :city, :state, :zip, :lat, :lon, :raw_address
  
  scope :active, where("active = true")
  
  def location
    return [poi.lat, poi.lon] unless poi.nil?
    return [lat, lon]
  end
  
  def to_s
    return name
  end
    
  def address
    if poi
      addr = poi.address
    else
      elems = []
      elems << address1 unless address1.blank?
      elems << address2 unless address2.blank?
      elems << city unless city.blank?
      elems << state unless state.blank?
      elems << zip unless zip.blank?
      addr = elems.compact.join(' ') 
      if addr.blank?
        addr = raw_address   
      end
    end
    return addr
  end
 
  def geocode
    return if raw_address.blank?
    # result = Geocoder.search(self.nongeocoded_address).as_json
    results = Geocoder.search(self.raw_address, sensor: false, components: Rails.application.config.geocoder_components, bounds: Rails.application.config.geocoder_bounds)
    if addr = results.first
      self.address1 = addr.street_address
      self.city     = addr.city
      self.zip      = addr.postal_code
      self.state    = addr.state_code
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
