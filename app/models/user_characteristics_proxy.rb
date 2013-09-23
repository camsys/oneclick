class UserCharacteristicsProxy < Proxy

  attr_accessor :user, :dob_month, :dob_day, :dob_year
  validate :validate_dob

  def initialize(user = nil)
    self.user = user

    super
  end

  def validate_dob
    dob = self.dob_day.to_s + '/' + self.dob_month.to_s + '/' + self.dob_year.to_s
    begin
      temp_date = Date.parse(dob)
    rescue
      errors.add(:dob_year, 'Please enter a valid date.')
      return false
    else
      return true
    end
  end

  def method_missing(code, *args)

    @code ||= TravelerCharacteristic.all.map(&:code)

    unless @code.include? code.to_s
      return super
    end

    characteristic = TravelerCharacteristic.find_by_code(code)
    map = UserTravelerCharacteristicsMap.where(characteristic_id: characteristic.id, user_profile_id: user.user_profile.id).first
    if map
      if code.to_s == 'date_of_birth'
        return map.value.to_date.to_formatted_s(:long)
      else
        return map.value
      end
    else
      return 'na'
    end
  end

  def update_maps(user_characteristics_settings)
    user_characteristics_maps = UserTravelerCharacteristicsMap.where(:user_profile_id => user.user_profile.id)
    user_characteristics_settings.each do |setting|
      characteristic = TravelerCharacteristic.where(:code => setting[0]).first

      if characteristic.nil?
        case setting[0]
          when 'dob_day'
            self.dob_day = setting[1]
          when 'dob_month'
            self.dob_month = setting[1]
          when 'dob_year'
            self.dob_year = setting[1]
        end
        next
      end

      map = user_characteristics_maps.where(:characteristic_id => characteristic.id, :user_profile_id => user.user_profile.id).first

      if setting[0] == 'date_of_birth'
        unless Chronic.parse(setting[1])
          errors.add(:date_of_birth, 'Please enter a valid date.')
          next
        end
      end

      if map.nil?
        UserTravelerCharacteristicsMap.create(:characteristic_id => characteristic.id, :user_profile_id => user.user_profile.id, value: setting[1])
      else
        map.value = setting[1]
        map.save()
      end

    end
  end

  def update_dob
    dob = self.dob_day.to_s + '/' + self.dob_month.to_s + '/' + self.dob_year.to_s
    characteristic = TravelerCharacteristic.where(:code => 'date_of_birth').first
    map = UserTravelerCharacteristicsMap.where(characteristic_id: characteristic.id, user_profile_id: user.user_profile.id).first

    if map.nil?
      UserTravelerCharacteristicsMap.create(:characteristic_id => characteristic.id, :user_profile_id => user.user_profile.id, value: dob)
    else
      map.value = dob
      map.save()
    end


  end

  def id
    return 1
  end

  def persisted?
    true
  end
end
