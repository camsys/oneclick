class ServiceType < ActiveRecord::Base
  #attr_accessible :id, :name, :note, :code
  has_many :services

  scope :available, -> { where(active: true)}

  def self.paratransit_ids
    ServiceType.where(code: ["paratransit", "volunteer", "nemt", "tap", "dial_a_ride"]).pluck(:id)
  end
end
