class UserRelationship < ActiveRecord::Base
  
  # Associations
  belongs_to :relationship_status
  belongs_to :traveler, :class_name => 'User', :foreign_key => 'user_id'
  belongs_to :delegate, :class_name => 'User'

end
