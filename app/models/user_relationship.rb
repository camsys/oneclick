class UserRelationship < ActiveRecord::Base
  
  # transient object
  attr_accessor :email
  
  # Associations
  belongs_to :relationship_status
  belongs_to :traveler, :class_name => 'User', :foreign_key => 'user_id'
  belongs_to :delegate, :class_name => 'User'

  def revokable
    relationship_status_id == RelationshipStatus::CONFIRMED
  end
  def acceptable
    relationship_status_id == RelationshipStatus::PENDING
  end
  def declinable
    relationship_status_id == RelationshipStatus::PENDING
  end

end
