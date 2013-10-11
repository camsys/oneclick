class Coverage < ActiveRecord::Base

  #associations
  has_many :service_coverage_maps
  has_many :services, through: :service_coverage_maps

  attr_accessible :zip

end
