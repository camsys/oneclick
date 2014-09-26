class MultiOriginDestTrip < ActiveRecord::Base
	belongs_to :user
	has_many :trips
end
