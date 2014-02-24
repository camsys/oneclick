class Mode < ActiveRecord::Base

  has_many :itineraries

  # Updatable attributes
  # attr_accessible :id, :name, :active
    
  PARATRANSIT = Mode.new name: 'Paratransit', active: true
  TRANSIT = Mode.new name: 'Transit', active: true
  TAXI = Mode.new name: 'Taxi', active: true
  RIDESHARE = Mode.new name: 'Rideshare', active: true

  # set the default scope
  default_scope {where('active = ?', true)}

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
