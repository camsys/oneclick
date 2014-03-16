class Role < ActiveRecord::Base

  # Associations
  has_many :user_roles
  has_many :users, through: :user_roles

  SYSTEM_ADMINISTRATOR = :system_administrator
  AGENCY_ADMINISTRATOR = :agency_administrator
  AGENT = :agent
  PROVIDER_STAFF = :provider_staff
  REGISTERED_TRAVELER = :registered_traveler
  ANONYMOUS_TRAVELER = :anonymous_traveler
  
  # # Updatable attributes
  # # attr_accessible :id, :name
  
end
