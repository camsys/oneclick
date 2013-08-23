class ServiceTripPurposeMap < ActiveRecord::Base

  #associations
  belongs_to :service
  belongs_to :trip_purpose


  attr_accessible :id, :value_relationship_id
end
