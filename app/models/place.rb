class Place < ActiveRecord::Base
  self.abstract_class = true

  # TODO decide where these happen
  # before_validation :geocode
  # validate :geocoded?

  attr_accessible :address, :address2, :city, :lat, :lon, :name, :state, :zip, :nongeocoded_address

  def geocode
    return if nongeocoded_address.blank?
    # result = Geocoder.search(self.nongeocoded_address).as_json
    result = Geocoder.search(self.nongeocoded_address, sensor: false,
      components: Rails.application.config.geocoder_components,
      bounds: Rails.application.config.geocoder_bounds).as_json
    unless result.length == 0
      self.lat = result[0]['data']['geometry']['location']['lat']
      self.lon = result[0]['data']['geometry']['location']['lng']
      self.address = result[0]['data']['formatted_address']
    end
    self
  end

  def geocode!
    self.geocode
  end

  def geocoded?
    if !(self.lat && self.lon)
      # TODO Check this, I think it adds new errors every time it gets called.
      errors.add(:nongeocoded_address, I18n.translate(:invalid_address))
      return false
    end
    true
  end

end
