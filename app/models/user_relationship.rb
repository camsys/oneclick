class UserRelationship < ActiveRecord::Base
  include RelationshipsHelper
  # transient object
  attr_accessor :email
  
  # Associations
  belongs_to :relationship_status
  belongs_to :traveler, :class_name => 'User', :foreign_key => 'user_id'
  belongs_to :delegate, :class_name => 'User'
  # belongs_to :buddy, :class_name => 'User', :foreign_key => 'user_id' # This is wrong, isn't it?  The buddy is FK'd to delegate ID?
  belongs_to :confirmed_traveler, -> {where 'relationship_status_id = 3'}, :class_name => 'User', :foreign_key => 'user_id'

  scope :not_hidden, -> {where('relationship_status_id != ?', RelationshipStatus::HIDDEN)}
  scope :with_user, ->(user) {where('delegate_id = ? OR user_id = ?', user.id, user.id)}
  scope :between_users, -> (user1, user2) { where('(delegate_id = ? and user_id = ?) OR (delegate_id = ? and user_id = ?)', user1.id, user2.id, user2.id, user1.id ) }

  def users
    [traveler, delegate]
  end

  def status
    relationship_status.human_readable
  end

  def to_s
    "#{traveler} has asked #{delegate} to assist them.\t#{status}"
  end
end
