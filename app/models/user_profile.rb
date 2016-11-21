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
    (age.nil? || !age.value) ? nil : age.value.to_i
  end

  def update_age(dob) #Takes DOB string in mm/dd/yyyy format

    dob = dob.split('/')
    unless dob.count == 3
      return nil
    end

    begin
      dob = (dob[1] + '/' + dob[0] + '/' + dob[2]).to_time
    rescue  ArgumentError
      return nil
    end

    now = Time.now

    age_characteristic = Characteristic.where(code: "age").first
    age = self.user_characteristics.where(characteristic: age_characteristic).first_or_initialize
    age.value = (now.year - dob.year - (dob.to_date.change(:year => now.year) > now ? 1 : 0)).to_s
    age.save
  end

end
