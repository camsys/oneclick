class UserModePreference < ActiveRecord::Base
  
  # Associations
  belongs_to :user
  belongs_to :mode

end
