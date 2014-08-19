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
    if c.datatype == 'date' and (rc.datatype == 'int' || rc.datatype == 'integer')
      return false if self.value.blank?
      age = Time.now - Time.parse(self.value)
      required = requirement.value.to_i.years
      Rails.logger.info "age: #{ActionController::Base.helpers.distance_of_time_in_words(age)}, req: #{ActionController::Base.helpers.distance_of_time_in_words(required)}, diff: #{ActionController::Base.helpers.distance_of_time_in_words(age - required)}"
      raise "Ask for birth date" if (required - age) < 1.year
      return test_condition(age, requirement.rel_code, required)
    end

    raise TypeError, "Don't know how to test char to req: #{self.ai} to #{requirement.ai} as #{c.datatype} == #{rc.datatype}"

  end

end
