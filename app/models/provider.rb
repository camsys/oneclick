class Provider < ActiveRecord::Base
  resourcify

  #associations
  has_many :services
  belongs_to :provider_org
  # attr_accessible :name, :contact, :external_id, :email, :contact_title, :address, :city, :state, :zip, :url, :phone

  include Validations
  before_validation :check_url_protocol

end
