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
end
