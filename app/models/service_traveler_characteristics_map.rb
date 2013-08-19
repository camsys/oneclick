class ServiceTravelerCharacteristicsMap < ActiveRecord::Base

  #associations
  belongs_to :service
  belongs_to :traveler_characteristic

  # attr_accessible :title, :body
end
