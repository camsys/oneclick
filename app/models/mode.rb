class Mode < ActiveRecord::Base
  
  # Updatable attributes
  attr_accessible :id, :name, :active
    
  # set the default scope
  default_scope where('active = true')

  def self.transit
    where('id = 1').first
  end
  def self.paratransit
    where('id = 2').first
  end
  def self.taxi
    where('id = 3').first
  end
end
