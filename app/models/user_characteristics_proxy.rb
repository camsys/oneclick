class UserCharacteristicsProxy < Proxy

  attr_accessor :user

  def initialize(user = nil)
    self.user = user
    super
  end

  def method_missing(name, *args)
    @name ||= TravelerCharacteristic.all.map(&:name)
    unless @name.include? name.to_s
      return super
    end

    characteristic = TravelerCharacteristic.find_by_name(name)
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
      characteristic = TravelerCharacteristic.where(:name => setting[0]).first
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
