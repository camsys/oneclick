class ServiceType < ActiveRecord::Base
  #attr_accessible :id, :name, :note, :code
  has_many :services

  scope :available, -> { where(active: true)}

  PARATRANSIT_MODE_NAMES = ["paratransit", "volunteer", "nemt", "tap", "dial_a_ride"]
  TAXI_MODE_NAMES = ["taxi"]
  TRANSIT_MODE_NAMES = ["transit", "rail", "bus", "ferry", "cable_car", "gondola", "funicular", "subway", "tram"]

  def self.paratransit_ids
    ServiceType.where(code: PARATRANSIT_MODE_NAMES).pluck(:id)
  end

  def self.transit_ids
    ServiceType.where(code: TRANSIT_MODE_NAMES).pluck(:id)
  end

  def self.taxi_ids
    ServiceType.where(code: TAXI_MODE_NAMES).pluck(:id)
  end
end
