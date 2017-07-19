class UserCharacteristic < ActiveRecord::Base
  include EligibilityOperators

  #associations
  belongs_to :user_profile
  belongs_to :characteristic, :class_name => "Characteristic", :foreign_key => "characteristic_id"

  #Some characteristics expire after a certain amount of time and need to be re-answered.
  def fresh?
    if self.characteristic.freshness_seconds.nil?
      return true
    else
      return (Time.now - self.updated_at) < self.characteristic.freshness_seconds
    end
  end

end
