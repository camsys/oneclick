class Poi < GeocodedAddress
  
  # Associations
  belongs_to :poi_type

  #after_validation :reverse_geocode
  
  # Updatable attributes
  # attr_accessible :name

  # set the default scope
  default_scope {order('pois.name')}

  def self.get_by_query_str(query_str, limit)
    rel = Poi.arel_table[:name].matches(query_str)
    pois = Poi.where(rel).limit(limit)
    pois
  end

  def to_s
    name
  end
  
  def county_name
    return get_county_name
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
      obj.address1  = geo.street_address
      obj.city      = geo.city
      obj.zip       = geo.postal_code
      obj.state     = geo.state_code
      obj.county    = geo.county
    end
  end

  def type_name
    'POI_TYPE'
  end
  
end
