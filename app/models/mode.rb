class Mode < ActiveRecord::Base
  
  # Updatable attributes
  attr_accessible :id, :name, :active
    
  # set the default scope
  default_scope where('active = ?', true)

  def self.transit
    where("name = 'Transit'").first
  end

  def self.paratransit
    where("name = 'Paratransit'").first
  end

  def self.taxi
    where("name = 'Taxi'").first
  end

  def self.rideshare
    where("name = 'Rideshare'").first
  end

  def to_s
    name
  end

end
