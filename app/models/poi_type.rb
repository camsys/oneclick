class PoiType < ActiveRecord::Base
  
  attr_accessible :name, :active
  
  # Associations
  has_many :pois
  
  def to_s
    name
  end
  
end
