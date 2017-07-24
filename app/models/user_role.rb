class UserRole < ActiveRecord::Base
  
  # Associations
  belongs_to :user
  belongs_to :role
  
  scope :professional, -> do
    joins(:role).where(roles: { name: ["system_administrator", "agency_administrator", "agent", "provider_staff", "internal_contact"] })
  end
  
end
