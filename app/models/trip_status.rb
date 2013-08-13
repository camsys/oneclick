class TripStatus < ActiveRecord::Base
  
  attr_accessible :id, :name, :active
  
  # set the default scope
  default_scope where('active = true')
  
end
