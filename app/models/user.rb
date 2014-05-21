class User < ActiveRecord::Base
  include ActiveModel::Validations

  # enable roles for this model
  rolify

  # See https://github.com/gonzalo-bulnes/simple_token_authentication
  acts_as_token_authenticatable

  # devise configuration
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

  # Needed to Rate Trips
  ajaxful_rater

  # Updatable attributes
  # attr_accessible :email, :password, :password_confirmation, :remember_me
  # attr_accessible :first_name, :last_name, :prefix, :suffix, :nickname
  # attr_accessible :role_ids 

  # Associations
  has_many :places, -> {where active: true} # 0 or more places, only active places are available
  has_many :trips                   # 0 or more trips
  has_many :trip_places, :through => :trips
  has_one  :user_profile            # 1 user profile
  has_many :user_mode_preferences   # 0 or more user mode preferences
  has_many :user_roles
  has_many :roles, :through => :user_roles # one or more user roles
  has_many :trip_parts, :through => :trips
  # relationships
  has_many :traveler_relationships, :class_name => 'UserRelationship', :foreign_key => :delegate_id
  has_many :confirmed_traveler_relationships, :class_name => 'UserRelationship', :foreign_key => :delegate_id
  has_many :travelers, :class_name => 'User', :through => :traveler_relationships
  has_many :confirmed_travelers, :class_name => 'User', :through => :confirmed_traveler_relationships
  
  has_many :delegate_relationships, :class_name => 'UserRelationship', :foreign_key => :user_id
  has_many :delegates, :class_name => 'User', :through => :delegate_relationships
  has_many :pending_and_confirmed_delegates, -> { where "user_relationships.relationship_status_id = ? OR user_relationships.relationship_status_id = ?", RelationshipStatus.confirmed, RelationshipStatus.pending }, 
    :class_name => 'User', :through => :delegate_relationships, :source => :delegate
  has_many :confirmed_delegates, -> { where "user_relationships.relationship_status_id = ?", RelationshipStatus.confirmed }, :class_name => 'User', :through => :delegate_relationships, :source => :delegate
  
  has_many :agency_user_relationships, foreign_key: :user_id
  accepts_nested_attributes_for :agency_user_relationships 
  has_many :approved_agencies,-> { where "agency_user_relationships.relationship_status_id = ?", RelationshipStatus.confirmed }, class_name: 'Agency', :through => :agency_user_relationships, source: :agency #Scope to only include approved relationships
  accepts_nested_attributes_for :approved_agencies

  # All User Relationships, including revoked, pending, and confirmed.  #TODO Is this a dupe of delegate_relationships?
  has_many :buddy_relationships, class_name: 'UserRelationship', foreign_key: :user_id
  accepts_nested_attributes_for :buddy_relationships
  has_many :buddies, class_name: 'User', through: :buddy_relationships, source: :delegate

  has_many :user_characteristics, through: :user_profile
  accepts_nested_attributes_for :user_characteristics
  has_many :characteristics, through: :user_characteristics
  
  has_many :user_accommodations, through: :user_profile
  accepts_nested_attributes_for :user_accommodations
  has_many :accommodations, through: :user_accommodations

  belongs_to :agency
  belongs_to :provider
  has_and_belongs_to_many :services

  scope :confirmed, -> {where('relationship_status_id = ?', RelationshipStatus::CONFIRMED)}
  scope :registered, -> {with_role(:registered_traveler)}
  # scope :buddyable, -> User.where.not(id: User.with_role(:anonymous_traveler).pluck(users: :id))
  scope :any_role, -> {joins(:roles)}

  # find all users which do not have the role passed in.  Need uniq because user could have multiple roles, i.e. multiple rows in user_roles table
  scope :without_role, ->(role_name) { joins(:user_roles).joins(:roles).where.not(roles: {name: role_name}).uniq }

  # Validations
  validates :email, :presence => true
  validates :first_name, :presence => true
  validates :last_name, :presence => true
  
  before_create :make_user_profile

  def make_user_profile
    create_user_profile
  end

  def to_s
    name
  end
    
  def name
    elems = []
    elems << prefix unless prefix.blank?
    elems << first_name unless first_name.blank?
    elems << last_name unless last_name.blank?
    elems << suffix unless suffix.blank?
    elems.compact.join(' ')
  end

  def welcome
    return nickname unless nickname.blank?
    return first_name unless first_name.blank?
    email
  end

  def has_disability?
    disabled = Characteristic.find_by_code('disabled')
    disability_status = self.user_profile.user_characteristics.where(characteristic_id: disabled.id)
    disability_status.count > 0 and disability_status.first.value == 'true'
  end

  def home
    self.places.find_by_home(true)
  end

  def clear_home
    old_homes = self.places.where(home: true)
    old_homes.each do |old_home|
      old_home.home = false
      old_home.save()
    end
  end

  # TODO Should be in decorator
  def email_and_agency
    agency.nil? ? email : "#{email} (#{agency.name})"
  end

  def is_visitor?
    role.includes
  end

  def is_registered?
    !is_visitor?
  end

  #List of users who can be assigned to staff for an agency or provider
  def self.staff_assignable
    User.where.not(id: User.with_role(:anonymous_traveler).pluck(:id)).order(first_name: :asc)
  end

  def set_buddies ids
    new_buddy_ids = ids.reject!(&:empty?)
    old_buddy_ids = pending_and_confirmed_delegates.pluck(:id).map(&:to_s) #hack.  Converting to strings for comparison to params hash

    new_buddies = new_buddy_ids - old_buddy_ids
    revoked_buddies = old_buddy_ids - new_buddy_ids

    # add or reset desired buddies
    new_buddies.each do |id|
      rel = UserRelationship.find_or_create_by!( traveler: self, delegate: User.find(id)) do |ur|
        ur.update_attributes(relationship_status: RelationshipStatus.pending)
      end
      rel.update_attributes(relationship_status: RelationshipStatus.pending)
    end
    # remove undesired buddies
    revoked_buddies.each do |revoked_id|
      buddy_relationships.find_by(delegate_id: revoked_id).update_attributes(relationship_status: RelationshipStatus.revoked)
    end
  end

end
