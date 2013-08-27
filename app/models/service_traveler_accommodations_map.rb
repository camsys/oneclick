class ServiceTravelerAccommodationsMap < ActiveRecord::Base

  #associations
  belongs_to :service
  belongs_to :traveler_accomodation

  # attr_accessible :title, :body
end
