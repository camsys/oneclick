class ServiceTripPurposeMap < ActiveRecord::Base

  #associations
  belongs_to :service
  belongs_to :trip_purpose

  attr_accessible :id, :service_id, :trip_purpose_id, :value, :active, :value_relationship_id

end
