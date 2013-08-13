class Place < ActiveRecord::Base

  # associations
  belongs_to :user  
  belongs_to :creator, :class_name => "User", :foreign_key => "creator_id"
  belongs_to :poi       # optional
  has_many :trip_places # optional
  
  attr_accessible :name, :address1, :address2, :city, :state, :zip, :lat, :lon, :raw_address
  
  def to_s
    if poi
      return poi.to_s
    else
      return name
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
