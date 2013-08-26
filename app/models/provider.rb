class Provider < ActiveRecord::Base

  #associations
  has_many :services
  attr_accessible :name, :contact, :external_id
end
