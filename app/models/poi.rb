class Poi < ActiveRecord::Base
  
  # Associations
  belongs_to :poi_type

  #after_validation :reverse_geocode
  
  # Updatable attributes
  attr_accessible :name, :address1, :address2, :city, :state, :zip, :lat, :lon

  # set the default scope
  default_scope where('pois.lat IS NOT NULL AND pois.lon IS NOT NULL').order('pois.name')
  
  def to_s
    name
  end
  
  def location
    return [lat, lon]
  end
  
  def geocode
    reverse_geocode
    self.save
  end
  
  def address
    #if address1.blank?
    #  reverse_geocode
    #  self.save
    #end
    elems = []
    elems << address1 unless address1.blank?
    elems << address2 unless address2.blank?
    elems << city unless city.blank?
    elems << state unless state.blank?
    elems << zip unless zip.blank?
    elems.compact.join(' ')
  end
  
  reverse_geocoded_by :lat, :lon do |obj,results|
    if geo = results.first
      obj.address1 = geo.street_address
      obj.city    = geo.city
      obj.zip     = geo.postal_code
      obj.state   = geo.state_code
    end
  end
  
end
