class PlaceProxy < Proxy

  attr_accessor :raw_address, :name, :place_type_id, :place_id, :id, :can_alter_location, :lat, :lon, :home
    
  validates :raw_address, :presence => true
  validates :name, :presence => true
 
  validate :validate_selection

  def initialize(attrs = {})
    super
    self.can_alter_location = true
    update(attrs)
  end

  def update(attrs = {})
    attrs.each do |k, v|
      self.send "#{k}=", v
    end
  end

protected
            
  def validate_selection
    if place_type_id.blank? 
      errors.add(:raw_address, I18n.translate(:nothing_found))
      return false      
    end
  end
            
end