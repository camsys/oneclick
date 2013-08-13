class UserRelationship < ActiveRecord::Base
  
  # Associations
  belongs_to :relationship_type
  belongs_to :user

end
