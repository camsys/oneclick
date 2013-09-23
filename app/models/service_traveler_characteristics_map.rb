class ServiceTravelerCharacteristicsMap < ActiveRecord::Base

  #associations
  belongs_to :service
  belongs_to :traveler_characteristic, :class_name => "TravelerCharacteristic", :foreign_key => "characteristic_id"

  attr_accessible :service, :service_id, :traveler_characteristic, :characteristic_id, :value, :value_relationship_id

end
