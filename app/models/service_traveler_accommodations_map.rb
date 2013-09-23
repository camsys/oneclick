class ServiceTravelerAccommodationsMap < ActiveRecord::Base

  #associations
  belongs_to :service
  belongs_to :traveler_accommodation, :class_name => "TravelerAccommodation", :foreign_key => "accommodation_id"

  attr_accessible :service, :service_id, :traveler_accommodation, :accommodation_id, :value

  # set the default scope
  #default_scope where('active = true')

end
