class UserRelationship < ActiveRecord::Base
  
  # transient object
  attr_accessor :email
  
  # Associations
  belongs_to :relationship_status
  belongs_to :traveler, :class_name => 'User', :foreign_key => 'user_id'
  belongs_to :delegate, :class_name => 'User'
  belongs_to :confirmed_traveler, :class_name => 'User', :foreign_key => 'user_id', :conditions => 'relationship_status_id = 3'

  default_scope where('relationship_status_id < ?', RelationshipStatus::HIDDEN)
  
  def revokable
    relationship_status_id == RelationshipStatus::CONFIRMED
  end
  def retractable
    relationship_status_id == RelationshipStatus::REQUESTED || relationship_status_id == RelationshipStatus::PENDING
  end
  def acceptable
    relationship_status_id == RelationshipStatus::PENDING
  end
  def declinable
    relationship_status_id == RelationshipStatus::PENDING
  end
  def hidable
    relationship_status_id == RelationshipStatus::REVOKED || relationship_status_id == RelationshipStatus::DENIED
  end

end
