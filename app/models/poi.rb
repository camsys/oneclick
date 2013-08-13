class Poi < ActiveRecord::Base
  
  # Associations
  belongs_to :poi_type
  
  # Updatable attributes
  attr_accessible :name, :address1, :address2, :city, :state, :zip, :lat, :lon

  # set the default scope
  default_scope where('active = true').order('poi_type')

  def to_s
    name
  end
  
end
