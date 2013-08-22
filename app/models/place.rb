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
 
end
