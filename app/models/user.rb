class User < ActiveRecord::Base
  rolify
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :role_ids, :as => :admin
  attr_accessible :email, :password, :password_confirmation, :remember_me

  # end devise/rolify

  attr_accessible :first_name, :last_name

  has_many :places, class_name: UserPlace 
  has_many :trips
  has_many :itineraries, :through => :trips
  has_many :buddy_relationships, foreign_key: :traveler_id
  has_many :traveler_relationships, class_name: BuddyRelationship, foreign_key: :buddy_id
  has_many :buddies, class_name: User, through: :buddy_relationships, conditions: "buddy_relationships.status='confirmed'"
  has_many :travelers, class_name: User, through: :traveler_relationships, conditions: "buddy_relationships.status='confirmed'"

  def name
    elems = []
    elems << first_name unless first_name.blank?
    elems << last_name unless last_name.blank?
    elems.compact.join(' ')
  end

  def welcome
    return first_name unless first_name.blank?
    email
  end

  def add_buddy email_address
    b = BuddyRelationship.new(email_address: email_address, status: 'pending')
    buddy_relationships << b
    unless self.save
      buddy_relationships.delete_if { |b| b.id.nil? }
    end
    b
  end

  def pending_buddy_requests
    traveler_relationships.pending
  end

  def pending_buddy? email_address
    buddy_by_status? email_address, 'pending'
  end

  def confirmed_buddy? email_address
    buddy_by_status? email_address, 'confirmed'
  end

  private

  def buddy_by_status? email_address, status
    buddy_relationships.find_by_email_address_and_status email_address, status
  end
end
