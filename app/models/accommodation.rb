class Accommodation < ActiveRecord::Base
  
  # attr_accessible :id, :code, :name, :note, :datatype, :active

  has_many :user_accommodations
  has_many :user_profiles, through: :user_accommodations

  has_many :service_accommodations
  has_many :services, through: :service_accommodations

  # set the default scope
  default_scope {where('accommodations.active = ?', true)}

end
