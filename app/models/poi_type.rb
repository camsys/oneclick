class PoiType < ActiveRecord::Base
  
  # attr_accessible :name, :active
  
  default_scope {where("poi_types.active = ?", true).order("poi_types.name")}
  
  # Associations
  has_many :pois
  
  def to_s
    name
  end
  
end
