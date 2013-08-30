class ServiceTravelerCharacteristicsMap < ActiveRecord::Base

  #associations
  belongs_to :service
  belongs_to :traveler_characteristic, :class_name => "TravelerCharacteristic", :foreign_key => "characteristic_id"

  attr_accessible :service_id, :characteristic_id, :value, :value_relationship_id

  # set the default scope
  default_scope where('active = true')

end
