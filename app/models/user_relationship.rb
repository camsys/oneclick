class UserRelationship < ActiveRecord::Base
  
  # Associations
  belongs_to :relationship_status
  belongs_to :user
  belongs_to :delegate, :class_name => 'User', :foreign_key => :delegate_id

end
