class UserCharacteristicsProxy < Proxy

  attr_accessor :user

  def initialize(user = nil)
    self.user = user
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
      return map.value
    else
      return 'na'
    end
  end

  def update_maps(user_characteristics_settings)
    user_characteristics_maps = UserTravelerCharacteristicsMap.where(:user_profile_id => user.user_profile.id)
    user_characteristics_settings.each do |setting|
      characteristic = TravelerCharacteristic.where(:code => setting[0]).first
      map = user_characteristics_maps.where(:characteristic_id => characteristic.id, :user_profile_id => user.user_profile.id).first
      if map.nil?
        UserTravelerCharacteristicsMap.create(:characteristic_id => characteristic.id, :user_profile_id => user.user_profile.id, value: setting[1])
      else
        map.value = setting[1]
        map.save()
      end

    end
  end

  def id
    return 1
  end

  def persisted?
    true
  end

end
