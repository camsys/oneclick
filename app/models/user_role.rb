class UserRole < ActiveRecord::Base
  
  # Associations
  belongs_to :user
  belongs_to :role
  
  scope :professional, -> do
    joins(:role).where(roles: { name: ["system_administrator", "provider_staff"] })
  end
  
end
