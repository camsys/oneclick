class User < ActiveRecord::Base
  include ActiveModel::Validations
  extend LocaleHelpers

  # enable roles for this model
  rolify

  # See https://github.com/gonzalo-bulnes/simple_token_authentication
  acts_as_token_authenticatable

  # devise configuration
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

  # Updatable attributes
  # attr_accessible :email, :password, :password_confirmation, :remember_me
  # attr_accessible :first_name, :last_name, :prefix, :suffix, :nickname
  # attr_accessible :role_ids

  # Associations
  has_many :places, -> {where active: true} # 0 or more places, only active places are available
  has_many :trips                   # 0 or more trips
  has_many :multi_o_d_trips
  has_many :trip_places, :through => :trips
  has_one  :user_profile            # 1 user profile
  has_many :user_mode_preferences   # 0 or more user mode preferences
  has_many :preferred_modes, through: :user_mode_preferences, class_name: 'Mode', source: :mode
  has_many :user_roles
  has_many :roles, :through => :user_roles # one or more user roles
  has_many :trip_parts, :through => :trips
  has_many :traveler_notes

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
  belongs_to :walking_speed
  belongs_to :walking_maximum_distance
  has_and_belongs_to_many :services

  has_many :ratings # ratings created by the user, not ratings of the user

  scope :confirmed, -> {where('relationship_status_id = ?', RelationshipStatus::CONFIRMED)}
  scope :registered, -> {with_role(:registered_traveler)}
  # scope :buddyable, -> User.where.not(id: User.with_role(:anonymous_traveler).pluck(users: :id))
  scope :any_role, -> {joins(:roles)}

  # find all users which do not have the role passed in.  Need uniq because user could have multiple roles, i.e. multiple rows in user_roles table
  scope :without_role, ->(role_name) { joins(:user_roles).joins(:roles).where.not(roles: {name: role_name}).uniq }

  scope :created_after, lambda {|from_day| where("users.created_at > ?", from_day.at_beginning_of_day) }
  scope :created_before, lambda {|to_day| where("users.created_at < ?", to_day.tomorrow.at_beginning_of_day) }
  scope :created_between, lambda {|from_day, to_day| created_after(from_day).created_before(to_day) }
  scope :active_between, lambda {|from_day, to_day| where("users.current_sign_in_at > ? AND users.current_sign_in_at < ?", from_day.at_beginning_of_day, to_day.tomorrow.at_beginning_of_day) }
  
  # Validations
  validates :email, :presence => true
  validates :first_name, :presence => true
  validates :last_name, :presence => true
  validates :maximum_wait_time, :numericality => { :greater_than_or_equal_to => 0}, if: :maximum_wait_time?

  before_create :make_user_profile

  def self.agent_form_collection include_all=true, agency=:any
    form_collection_from_relation(include_all,
                                  # any_role.where(roles: {name: 'agent'}).order(:first_name),
                                  with_role(:agent, agency).order(:first_name),
                                  false)
  end

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
    return false if disabled.nil?
    disability_status = self.user_profile.user_characteristics.where(characteristic_id: disabled.id)
    disability_status.count > 0 and disability_status.first.value == 'true'
  end

  def requires_wheelchair_access?
    folding_accommodation = Accommodation.where(code: 'folding_wheelchair_accessible').first
    motorized_accommodation = Accommodation.where(code: 'motorized_wheelchair_accessible').first

    needs_folding = user_profile.user_accommodations.where(accommodation: folding_accommodation, value: "true").first
    needs_motorized = user_profile.user_accommodations.where(accommodation: motorized_accommodation, value: "true").first

    if needs_folding or needs_motorized
      return true
    else
      return false
    end

  end

  def has_vehicle?
    has_trans = Characteristic.find_by(code: 'no_trans')
    return false if has_trans.nil?
    status = self.user_profile.user_characteristics.where(characteristic: has_trans)
    status.count > 0 and status.first.value == 'true'
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

  def age
    return self.user_profile.age
  end

  def is_visitor?
    has_role? :anonymous_traveler
  end

  def is_registered?
    !is_visitor?
  end

  def can_book?
    unless self.user_profile.services.empty?
      return true
    end
    false
  end

  def is_staff? #If this user has any role beyond traveler, then return true
    if self.roles.where.not(name: ["registered_traveler", "anonymous_traveler"]).count > 0
      return true
    else
      return false
    end
  end

  def max_wait_time
    if !maximum_wait_time
      default_max_wait_time = Oneclick::Application.config.default_max_wait_time 
      return default_max_wait_time if default_max_wait_time
    end

    maximum_wait_time
  end

  # Union to get unique users with any relationship to current user
  def related_users
    delegates | travelers
  end

  def can_assist_target?(user)
    self.travelers.include? user
  end

  def can_be_assisted_by_target?(user)
    self.confirmed_delegates.include? user
  end

  #List of users who can be assigned to staff for an agency or provider
  def self.staff_assignable
    User.without_role(:anonymous_traveler).where(deleted_at: nil).order(first_name: :asc)
  end

  def update_relationships id_hash
    if id_hash
      id_hash.each do |rel_id, rel_status|
        UserRelationship.find(rel_id).update_attributes(relationship_status_id: rel_status)
      end
    end
  end

  def add_buddies emails
    unless emails.nil?
      emails.each do |email|
        rel = UserRelationship.find_or_create_by(user_id: self.id, delegate_id: User.find_by(email: email).id) do |ur|
          ur.relationship_status_id = RelationshipStatus::PENDING
        end
        UserMailer.buddy_request_email(rel.delegate.email, rel.traveler).deliver
      end
    end
  end

  def soft_delete
    update_attribute(:deleted_at, Time.current)
  end

  def active_for_authentication?
    super && !deleted_at
  end

  def undelete
    update_attribute(:deleted_at, nil)
  end
end
