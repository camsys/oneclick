class Place < ActiveRecord::Base
  before_validation :geocode
  validate :geocoded?
  attr_accessor :nongeocoded_address
  attr_accessible :address, :address2, :city, :lat, :lon, :name, :state, :zip, :nongeocoded_address
  belongs_to :owner, foreign_key: 'user_id', class_name: User

  def geocode
    result = Geocoder.search(self.nongeocoded_address).as_json
    if result.length == 0
      return nil
    end
    self.lat = result[0]['data']['geometry']['location']['lat']
    self.lon = result[0]['data']['geometry']['location']['lng']
    self.address = result[0]['data']['formatted_address']
  end

  def geocoded?
    if !(self.lat && self.lon)
      errors.add(:nongeocoded_address, I18n.translate(:invalid_address))
    end
  end

end
