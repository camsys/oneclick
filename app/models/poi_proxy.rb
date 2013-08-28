class PoiProxy < Proxy

  attr_accessor :poi_type_id, :poi_id, :name
    
  validates :poi_id, :presence => true
  validates :name, :presence => true
  
  def initialize(attrs = {})
    super
    attrs.each do |k, v|
      self.send "#{k}=", v
    end
  end
  
end