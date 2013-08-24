class PlaceProxy < Proxy

  attr_accessor :raw_address, :name
    
  validates :raw_address, :presence => true
  validates :name, :presence => true
            
end