class User < ActiveRecord::Base

  # enable roles for this model
  rolify
  
  # devise configuration
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

  # Updatable attributes
  attr_accessible :email, :password, :password_confirmation, :remember_me
  attr_accessible :first_name, :last_name, :prefix, :suffix, :nickname

  # Associations
  has_many :places, :conditions => ['active = ?', true] # 0 or more places, only active places are available
  has_many :trips                   # 0 or more trips
  has_many :trip_places, :through => :trips
  has_one  :user_profile            # 1 user profile
  has_many :user_mode_preferences   # 0 or more user mode preferences
  has_many :user_roles
  has_many :roles, :through => :user_roles # one or more user roles
  has_many :planned_trips, :through => :trips
  # relationships
  has_many :delegate_relationships, :class_name => 'UserRelationship', :foreign_key => :user_id
  has_many :traveler_relationships, :class_name => 'UserRelationship', :foreign_key => :delegate_id
  has_many :delegates, :class_name => 'User', :through => :delegate_relationships
  has_many :travelers, :class_name => 'User', :through => :traveler_relationships

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

    disabled = TravelerCharacteristic.find_by_code('disabled')
    disability_status = self.user_profile.user_traveler_characteristics_maps.where(characteristic_id: disabled.id)
    disability_status.count > 0 and disability_status.first.value == 'true'

  end

end
