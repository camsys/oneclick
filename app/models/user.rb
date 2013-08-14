class User < ActiveRecord::Base

  # enable roles for this model
  rolify
  
  # devise configuration
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

  # Updatable attributes
  attr_accessible :email, :password, :password_confirmation, :remember_me
  attr_accessible :first_name, :last_name, :prefix, :suffix, :nickname

  # Associations
  has_many :places                  # 0 or more places
  has_many :trips                   # 0 or more trips
  has_many :user_relationships      # 0 or more relationships
  has_one  :user_profile            # 1 user profile
  has_many :user_mode_preferences   # 0 or more user mode preferences
  has_many :user_roles
  has_many :roles, :through => :user_roles # one or more user roles
  has_many :planned_trips, :through => :trips
  # relationships
  has_many :user_relationships
  has_many :delegates, :class_name => 'User', :foreign_key => :delegate_id, :through => :user_relationships
  has_many :travelers, :class_name => 'User', :foreign_key => :user_id, :through => :user_relationships

  # Validations
  validates :email, :presence => true
  validates :first_name, :presence => true
  validates :last_name, :presence => true

    
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

end
