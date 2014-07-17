class UserCharacteristic < ActiveRecord::Base
  include EligibilityOperators

  #associations
  belongs_to :user_profile
  belongs_to :characteristic, :class_name => "Characteristic", :foreign_key => "characteristic_id"

  # attr_accessible :user_profile_id, :user_profile, :characteristic, :characteristic_id, :value

  def meets_requirement requirement
    c = characteristic
    rc = requirement.characteristic
    if c.datatype==rc.datatype
      return test_condition(value, requirement.rel_code, requirement.value)
    end

    # only other thing we currently handle is comparing dob (date) to age (int)
    if c.datatype=='date' and rc.datatype=='integer'
      return false if self.value.blank?
      return test_condition(Time.now - Time.parse(self.value), requirement.rel_code, requirement.value.to_i.years)
    end

    raise "Don't know how to test char to req: #{self.ai} to #{requirement.ai}"

  end

end
