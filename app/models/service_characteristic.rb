class ServiceCharacteristic < ActiveRecord::Base

  #associations
  belongs_to :service
  belongs_to :characteristic, :class_name => "Characteristic", :foreign_key => "characteristic_id"

  attr_accessible :service, :service_id, :characteristic, :characteristic_id, :value, :value_relationship_id, :group

end
