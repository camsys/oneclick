class TripPlace < ActiveRecord::Base

  TYPES = [
    "Poi",
    "Place",
    "Street Address"
  ]
  # Associations
  belongs_to :trip    # everyone trip place must belong to a trip
  belongs_to :place   # optional
  belongs_to :poi   # optional
  
  # Updatable attributes
  attr_accessible :sequence, :raw_address, :lat, :lon
  
  # set the default scope
  default_scope order('sequence ASC')
  
  def location
    return poi.location unless poi.nil?
    return place.location unless place.nil?
    return [lat, lon]
  end
  
  def type
    return TYPES[0] unless poi.nil?
    return TYPES[1] unless place.nil?
    return TYPES[2]
  end
  
  def to_s
    return poi.to_s unless poi.nil?
    return place.to_s unless place.nil?
    return raw_address
  end    
end
