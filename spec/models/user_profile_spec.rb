require 'spec_helper'

describe UserProfile do

  [ActiveSupport::TimeZone.new('UTC'),
    ActiveSupport::TimeZone.new('Eastern Time (US & Canada)'),
    ActiveSupport::TimeZone.new('Pacific Time (US & Canada)'),
    ].each do |tz|
      describe "in timezone #{tz}" do
        it "has eligible services for traveler and trip" do
          # Jut leaving this here as an example of how to print out info about the current example
          # puts
          # puts example.metadata[:full_description].to_s
          pending "todo"
          Time.zone = tz
          user_profile = FactoryGirl.create(:user_profile)
          eh = EligibilityHelpers.new
          all_services = Service.all
          expect(all_services.size).to eq 10
          services = eh.get_eligible_services_for_traveler(user_profile)
          expect(services.size).to eq 2
          planned_trip = FactoryGirl.create(:trip_part)
          purpose = TripPurpose.find_by_name('Medical')
          planned_trip.trip.trip_purpose = purpose
          services = eh.get_eligible_services_for_trip(planned_trip, services)
          expect(    services.size).to eq 2
        end

        it "has eligible services for traveler but not trip" do
          pending "todo"
          Time.zone = tz
          user_profile = FactoryGirl.create(:user_profile)
          eh = EligibilityHelpers.new
          services = eh.get_eligible_services_for_traveler(user_profile)
          expect(    services.size).to eq 2
          planned_trip = FactoryGirl.create(:trip_part2)
          purpose = TripPurpose.find_by_name('Medical')
          planned_trip.trip.trip_purpose = purpose
          services = eh.get_eligible_services_for_trip(planned_trip, services)
          expect(    services.size).to eq 0
        end

        it "is eligible for all five seeded services" do
          pending "todo"
          Time.zone = tz
          user_profile = FactoryGirl.create(:user_profile)
          eh = EligibilityHelpers.new
          characteristics = Characteristic.all
          characteristics.each do |c|
            if c.code == 'date_of_birth'
              UserTravelerCharacteristicsMap.find_or_create_by_user_profile_id_and_characteristic_id(user_profile_id: user_profile.id, characteristic_id: c.id, value: '05/11/1905')
            elsif c.code != 'age'
              UserTravelerCharacteristicsMap.find_or_create_by_user_profile_id_and_characteristic_id(user_profile_id: user_profile.id, characteristic_id: c.id, value: 'true')
            end
          end
          acc_and_eligible_services = eh.get_accommodating_and_eligible_services_for_traveler(user_profile)
          expect(acc_and_eligible_services.size).to eq 10
          planned_trip = FactoryGirl.create(:trip_part)
          purpose = TripPurpose.find_by_name('Medical')
          planned_trip.trip.trip_purpose = purpose
          services2 = eh.get_eligible_services_for_trip(planned_trip, acc_and_eligible_services)
          expect(services2.size).to eq 9
        end

        it "has 5 eligible services for the traveler and x for the trip" do
          pending "todo"
          Time.zone = tz
          user_profile = FactoryGirl.create(:user_profile)
          eh = EligibilityHelpers.new
          characteristics = Characteristic.all
          characteristics.each do |c|
            if c.code == 'date_of_birth'
              UserTravelerCharacteristicsMap.find_or_create_by_user_profile_id_and_characteristic_id(user_profile_id: user_profile.id, characteristic_id: c.id, value: '05/11/1905')
            elsif c.code != 'age'
              UserTravelerCharacteristicsMap.find_or_create_by_user_profile_id_and_characteristic_id(user_profile_id: user_profile.id, characteristic_id: c.id, value: 'true')
            end
          end
          services = eh.get_eligible_services_for_traveler(user_profile)
          expect(    services.size).to eq 10
          planned_trip = FactoryGirl.create(:trip_part)
          purpose = TripPurpose.find_by_name('Personal')
          planned_trip.trip.trip_purpose = purpose
          services = eh.get_eligible_services_for_trip(planned_trip, services)
          expect(    services.size).to eq 0
        end
      end

    end
  end