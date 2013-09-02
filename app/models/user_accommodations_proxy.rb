class UserAccommodationsProxy < Proxy

  attr_accessor :user

  def initialize(user = nil)
    self.user = user
    super
  end

  def method_missing(name, *args)
    @name ||= TravelerAccommodation.all.map(&:name)
    unless @name.include? name.to_s
      return super
    end

    accommodation = TravelerAccommodation.find_by_name(name)
    map = UserTravelerAccommodationsMap.where(accommodation_id: accommodation.id, user_profile_id: user.user_profile.id).first

    if map
      return map.value
    else
      return 'na'
    end
  end

  def update_maps(user_accommodations_settings)
    user_accommodations_maps = UserTravelerAccommodationsMap.where(:user_profile_id => user.user_profile.id)
    user_accommodations_settings.each do |setting|
      accommodation = TravelerAccommodation.where(:name => setting[0]).first
      map = user_accommodations_maps.where(:accommodation_id => accommodation.id, :user_profile_id => user.user_profile.id).first
      if map.nil?
        UserTravelerAccommodationsMap.create(:accommodation_id => accommodation.id, :user_profile_id => user.user_profile.id, value: setting[1])
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
