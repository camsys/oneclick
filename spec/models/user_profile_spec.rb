require 'spec_helper'

describe UserProfile do

  it "has eligible services for traveler and trip" do
    user_profile = FactoryGirl.create(:user_profile)
    eh = EligibilityHelpers.new
    all_services = Service.all
    all_services.count.should eq 5
    services = eh.get_eligible_services_for_traveler(user_profile)
    services.count.should eq 2
    planned_trip = FactoryGirl.create(:trip_with_places)
    purpose = TripPurpose.find_by_name('Medical')
    planned_trip.trip.trip_purpose = purpose
    services = eh.get_eligible_services_for_trip(planned_trip, services)
    services.count.should eq 2
  end

  it "has eligible services for traveler but not trip" do
    user_profile = FactoryGirl.create(:user_profile)
    eh = EligibilityHelpers.new
    services = eh.get_eligible_services_for_traveler(user_profile)
    services.count.should eq 2
    planned_trip = FactoryGirl.create(:trip_with_places2)
    purpose = TripPurpose.find_by_name('Medical')
    planned_trip.trip.trip_purpose = purpose
    services = eh.get_eligible_services_for_trip(planned_trip, services)
    services.count.should eq 0
  end

  it "is eligible for all five seeded services" do
    user_profile = FactoryGirl.create(:user_profile)
    Rails.logger.info user_profile.ai
    eh = EligibilityHelpers.new
    characteristics = TravelerCharacteristic.all
    Rails.logger.info characteristics
    Rails.logger.info "---each characteristics---"
    characteristics.each do |c|
      Rails.logger.info "characteristic: #{c.code}"
      if c.code == 'date_of_birth'
        Rails.logger.info 'before start or create'
        utcm = UserTravelerCharacteristicsMap.find_or_create_by_user_profile_id_and_characteristic_id(user_profile_id: user_profile.id, characteristic_id: c.id, value: '05/11/1905')
        Rails.logger.info 'after start or create'
      elsif c.code != 'age'
        Rails.logger.info 'before start or create'
        utcm = UserTravelerCharacteristicsMap.find_or_create_by_user_profile_id_and_characteristic_id(user_profile_id: user_profile.id, characteristic_id: c.id, value: 'true')
        Rails.logger.info 'after start or create'
      end
    end
    Rails.logger.info "---done each characteristics, get services---"
    acc_and_eligible_services = eh.get_accommodating_and_eligible_services_for_traveler(user_profile)
    Rails.logger.info "done getting services"
    Rails.logger.info acc_and_eligible_services.ai
    Rails.logger.info "count: #{acc_and_eligible_services.count.ai}"
    acc_and_eligible_services.size.should eq 5
    planned_trip = FactoryGirl.create(:trip_with_places)
    purpose = TripPurpose.find_by_name('Medical')
    planned_trip.trip.trip_purpose = purpose
    services2 = eh.get_eligible_services_for_trip(planned_trip, acc_and_eligible_services)
    services2.size.should eq 5
  end

  it "It has 5 eligible services for the traveler and x for the trip" do
    user_profile = FactoryGirl.create(:user_profile)
    eh = EligibilityHelpers.new
    characteristics = TravelerCharacteristic.all
    characteristics.each do |c|
      if c.code == 'date_of_birth'
        UserTravelerCharacteristicsMap.find_or_create_by_user_profile_id_and_characteristic_id(user_profile_id: user_profile.id, characteristic_id: c.id, value: '05/11/1905')
      elsif c.code != 'age'
        UserTravelerCharacteristicsMap.find_or_create_by_user_profile_id_and_characteristic_id(user_profile_id: user_profile.id, characteristic_id: c.id, value: 'true')
      end
    end
    services = eh.get_eligible_services_for_traveler(user_profile)
    services.count.should eq 5
    planned_trip = FactoryGirl.create(:trip_with_places)
    purpose = TripPurpose.find_by_name('Personal')
    planned_trip.trip.trip_purpose = purpose
    services = eh.get_eligible_services_for_trip(planned_trip, services)
    services.count.should eq 0
  end

end