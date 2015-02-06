class UserProfile < ActiveRecord::Base

  # Associations
  belongs_to :user
  has_many :user_characteristics
  has_many :user_accommodations
  has_many :user_services

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
    age_characteristic = Characteristic.where(code: "age").first
    age = self.user_characteristics.where(characteristic: age_characteristic).first
    age.nil? ? nil : age.value.to_i
  end

end

