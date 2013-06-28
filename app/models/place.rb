class Place < ActiveRecord::Base
  attr_accessible :address, :address2, :city, :lat, :lon, :name, :state, :zip
  belongs_to :owner, foreign_key: 'user_id', class_name: User
end
