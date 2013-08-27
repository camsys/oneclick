class UserTravelerCharacteristicsMap < ActiveRecord::Base
  #associations
  belongs_to :traveler, :class_name => 'User'
  belongs_to :traveler_characteristic
  # attr_accessible :title, :body
end
