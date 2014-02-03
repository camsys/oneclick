class Role < ActiveRecord::Base

  # Associations
  has_many :user_roles
  has_many :users, through: :user_roles
  
  # Updatable attributes
  attr_accessible :id, :name
  
end
