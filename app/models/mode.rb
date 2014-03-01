class Mode < ActiveRecord::Base

  has_many :itineraries

  # Updatable attributes
  # attr_accessible :id, :name, :active
    
  # TODO Unclear if we should have these constants any more
  PARATRANSIT = Mode.new name: 'Paratransit', active: true
  TRANSIT = Mode.new name: 'Transit', active: true
  TAXI = Mode.new name: 'Taxi', active: true
  RIDESHARE = Mode.new name: 'Rideshare', active: true

  # set the default scope
  default_scope {where('active = ?', true)}

  def self.transit
    where("code = 'mode_transit'").first
  end

  def self.paratransit
    where("code = 'mode_paratransit'").first
  end

  def self.taxi
    where("code = 'mode_taxi'").first
  end

  def self.rideshare
    where("code = 'mode_rideshare'").first
  end

  def to_s
    name
  end

end
