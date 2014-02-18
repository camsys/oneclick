class GeocodedAddress < ActiveRecord::Base
  self.abstract_class = true  
  
  # # attr_accessible :address1, :address2, :city, :state, :zip
  # # attr_accessible :lat, :lon
  # # attr_accessible :county

protected

  def get_zipcode
    return zip
  end
  
  def get_location
    return [lat, lon]
  end

  def get_county_name
    return county
  end

  def get_address
    elems = []
    elems << address1 unless address1.blank?
    elems << address2 unless address2.blank?
    elems << city unless city.blank?
    elems << state unless state.blank?
    elems << zip unless zip.blank?
    addr = elems.compact.join(' ') 
    return addr
  end
  
end