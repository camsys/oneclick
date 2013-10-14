class Poi < GeocodedAddress
  
  # Associations
  belongs_to :poi_type

  #after_validation :reverse_geocode
  
  # Updatable attributes
  attr_accessible :name

  # set the default scope
  default_scope order('pois.name')
  
  def to_s
    name
  end
  
  def location
    return get_location
  end
  
  def zipcode
    return get_zipcode
  end
  
  def geocode
    reverse_geocode
    self.save
  end
  
  def address
    get_address
  end
  
  reverse_geocoded_by :lat, :lon do |obj, results|
    if results.first
      geo = results.first
      obj.address1 = geo.street_address
      obj.city    = geo.city
      obj.zip     = geo.postal_code
      obj.state   = geo.state_code
    end
  end
  
end
