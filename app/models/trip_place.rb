class TripPlace < ActiveRecord::Base

  TYPES = [
    "Place",
    "Street Address"
  ]
  # Associations
  belongs_to :trip    # everyone trip place must belong to a trip
  belongs_to :place   # optional
  
  # Updatable attributes
  attr_accessible :sequence, :raw_address, :lat, :lon
  
  # set the default scope
  default_scope order('sequence ASC')
  
  def location
    return [place.lat, place.lon] unless place.nil?
    return [lat, lon]
  end
  
  def type
    return TYPES[0] unless place.nil?
    return TYPES[1]
  end
  
  def to_s
    if place
      return place.to_s
    else
      return raw_address
    end
  end
    
end
