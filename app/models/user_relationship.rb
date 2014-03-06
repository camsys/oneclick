class UserRelationship < ActiveRecord::Base
  include RelationshipsHelper
  # transient object
  attr_accessor :email
  
  # Associations
  belongs_to :relationship_status
  belongs_to :traveler, :class_name => 'User', :foreign_key => 'user_id'
  belongs_to :delegate, :class_name => 'User'
  belongs_to :buddy, :class_name => 'User', :foreign_key => 'user_id'
  belongs_to :confirmed_traveler, -> {where 'relationship_status_id = 3'}, :class_name => 'User', :foreign_key => 'user_id'

  scope :not_hidden, -> {where('relationship_status_id != ?', RelationshipStatus::HIDDEN)}

end
