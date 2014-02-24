class UserProfile < ActiveRecord::Base

  # Associations
  belongs_to :user
  has_many :user_characteristics
  has_many :user_accommodations

  has_many :accommodations, through: :user_accommodations, source: :accommodation
  has_many :characteristics, through: :user_characteristics, source: :characteristic

  def has_characteristics?
    if self.characteristics.count > 0
      true
    else
      false
    end
  end

end

