class UserProfile < ActiveRecord::Base

  # Associations
  belongs_to :user
  has_many :user_characteristics
  has_many :user_accommodations
  has_many :user_services, :dependent => :destroy

  has_many :accommodations, through: :user_accommodations, source: :accommodation
  has_many :characteristics, through: :user_characteristics, source: :characteristic
  has_many :services, through: :user_services, source: :service


  def has_characteristics?
    if self.characteristics.count > 0
      true
    else
      false
    end
  end

  def age
    self.user.age
  end

  def update_age(dob) #Takes DOB string in mm/dd/yyyy format
    return self.user.update_age(dob)
  end

end
