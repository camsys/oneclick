class EligibilityHelpers

  def get_eligible_services(user_profile)

    #user characteristics
    characteristic_maps = user_profile.user_traveler_characteristics_maps
    user_characteristics = []
    characteristic_maps.each do |map|
      user_characteristics << map.traveler_characteristic
    end

    #service characteristics
    #TODO: There must be a better way that looping through these services
    eligible_services = []
    all_services = Service.all
    all_services.each do |service|
      characteristic_maps = service.service_traveler_characteristics_maps
      service_characteristics  = []
      characteristic_maps.each do |map|
        service_characteristics << map.traveler_characteristic
      end

      if service_characteristics.count == (service_characteristics & user_characteristics).count
        eligible_services << service
      end

    end
    eligible_services
  end

  def get_accommodating_services(user_profile)
    #user accommodations
    accommodations_maps = user_profile.user_traveler_accommodations_maps
    user_accommodations = []
    accommodations_maps.each do |map|
      user_accommodations << map.traveler_accommodation
    end

    #service accommodations
    #TODO: There must be a better way that looping through these services
    accommodating_services = []
    all_services = Service.all
    all_services.each do |service|
      accommodations_maps = service.service_traveler_accommodations_maps
      service_accommodations  = []
      accommodations_maps.each do |map|
        service_accommodations << map.traveler_accommodation
      end

      if user_accommodations.count == (service_accommodations & user_accommodations).count
        accommodating_services << service
      end

    end
    accommodating_services
  end


  def get_accommodating_and_eligible_services(user_profile)
    eligible = user_profile.get_eligible_services(user_profile)
    accommodating = user_profile.get_accommodating_services(user_profile)
    eligible & accommodating
  end

end