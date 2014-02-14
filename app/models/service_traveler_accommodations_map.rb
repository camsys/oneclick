class ServiceTravelerAccommodationsMap < ActiveRecord::Base

  #associations
  belongs_to :service
  belongs_to :accommodation, :class_name => "Accommodation", :foreign_key => "accommodation_id"

  attr_accessible :service, :service_id, :accommodation, :accommodation_id, :value

  # set the default scope
  #default_scope where('active = true')

end
