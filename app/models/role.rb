class Role < ActiveRecord::Base
  HUMAN_READABLE_NAMES = {
    system_administrator: "Sys Admin",
    agency_administrator: "Agency Admin",
    agent: "Agency Agent",
    provider_staff: "Provider Admin",
    registered_traveler: "Registered Traveler",
    anonymous_traveler: "Visitor",
    internal_contact: "Contact"
  }
  # Associations
  has_many :user_roles
  has_many :users, through: :user_roles

  SYSTEM_ADMINISTRATOR = :system_administrator
  AGENCY_ADMINISTRATOR = :agency_administrator
  AGENT = :agent
  PROVIDER_STAFF = :provider_staff
  REGISTERED_TRAVELER = :registered_traveler
  ANONYMOUS_TRAVELER = :anonymous_traveler
  INTERNAL_CONTACT = :internal_contact
  
  # # Updatable attributes
  # # attr_accessible :id, :name
  def human_readable_name
    HUMAN_READABLE_NAMES[name.to_sym]
  end
end
