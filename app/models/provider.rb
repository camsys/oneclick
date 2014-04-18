class Provider < ActiveRecord::Base
  resourcify

  #associations
  has_many :users
  has_many :services
  
  include Validations
  before_validation :check_url_protocol

end
