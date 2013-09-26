class UserCharacteristicsProxy < Proxy

  attr_accessor :user, :date_of_birth
  validates :date_of_birth, :presence => true

  def initialize(user = nil)
    self.user = user
    date_of_birth = Date.today
    super
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
    characteristic = TravelerCharacteristic.where(:code => 'date_of_birth').first
    map = UserTravelerCharacteristicsMap.where(characteristic_id: characteristic.id, user_profile_id: user.user_profile.id).first

    if map.nil?
      UserTravelerCharacteristicsMap.create(:characteristic_id => characteristic.id, :user_profile_id => user.user_profile.id, value: date_of_birth)
    else
      map.value = date_of_birth
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
