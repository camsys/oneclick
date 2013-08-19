class Providers < ActiveRecord::Base

  #associations
  has_many :services
  # attr_accessible :title, :body
end
