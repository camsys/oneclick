class UserRelationship < ActiveRecord::Base
  include RelationshipsHelper
  # transient object
  attr_accessor :email
  
  # Associations
  belongs_to :relationship_status
  belongs_to :traveler, :class_name => 'User', :foreign_key => 'user_id'
  belongs_to :delegate, :class_name => 'User'
  belongs_to :buddy, :class_name => 'User', :foreign_key => 'user_id' # This is wrong, isn't it?  The buddy is FK'd to delegate ID?  The traveler is
  belongs_to :confirmed_traveler, -> {where 'relationship_status_id = 3'}, :class_name => 'User', :foreign_key => 'user_id'

  scope :not_hidden, -> {where('relationship_status_id != ?', RelationshipStatus::HIDDEN)}
  scope :with_user, ->(user) {where('delegate_id = ? OR user_id = ?', user.id, user.id)}

  def users
    [traveler, delegate]
  end
end
