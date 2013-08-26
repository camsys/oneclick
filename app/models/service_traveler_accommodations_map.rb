class ServiceTravelerAccommodationsMap < ActiveRecord::Base

  #associations
  belongs_to :service
  belongs_to :traveler_accommodation, :class_name => "TravelerAccommodation", :foreign_key => "accommodation_id"

  attr_accessible :service_id, :accommodation_id, :value

end
