class EcolaneProfile < ActiveRecord::Base
  belongs_to :service

  serialize :booking_counties # List of counties whose residents can book through this service
end
