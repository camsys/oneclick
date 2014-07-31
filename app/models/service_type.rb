class ServiceType < ActiveRecord::Base
  #attr_accessible :id, :name, :note, :code
  has_many :services
end
