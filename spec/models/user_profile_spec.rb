require 'spec_helper'

describe UserProfile do

  before(:each) do
    @user_profile = FactoryGirl.create(:user_profile)
    @service1 = FactoryGirl.create(:populated_service)
    @service2 = FactoryGirl.create(:populated_service)
    @restricted_service = FactoryGirl.create(:restricted_service)
  end

 test_timezones = [ActiveSupport::TimeZone.new('UTC'),
    ActiveSupport::TimeZone.new('Eastern Time (US & Canada)'),
    ActiveSupport::TimeZone.new('Pacific Time (US & Canada)'),
    ]
    [test_timezones[1]].each do |tz|
      describe "in timezone #{tz}" do
        it "has eligible services for traveler and trip" do
          pending "to-refactor"
          # Jut leaving this here as an example of how to print out info about the current example
          # puts
          # puts example.metadata[:full_description].to_s
          Time.zone = tz
          eh = EligibilityService.new
          all_services = Service.all
          expect(all_services.size).to eq 3
          services = eh.get_eligible_services_for_traveler(@user_profile)
          # puts services.ai
          # services.each do |se|
          #   sv = se['service']
          #   puts "*********"
          #   puts sv.characteristics.size
          #   puts sv.characteristics.ai
          #   puts "END"
          # end
          expect(services.size).to eq 3
          trip = FactoryGirl.create(:trip, trip_purpose: TripPurpose.find_by_name('Medical'))
          planned_trip_part = trip.trip_parts.first
          services = eh.remove_ineligible_itineraries(planned_trip_part, services)
          expect(services.size).to eq 3
        end

        it "has eligible services for traveler but not trip" do
          pending "todo"
          # THIS TEST IS NOT VALID YET
          Time.zone = tz
          eh = EligibilityService.new
          services = eh.get_eligible_services_for_traveler(@user_profile)
          expect(    services.size).to eq 3
          trip = FactoryGirl.create(:trip2, trip_purpose: TripPurpose.find_by_name('Medical'))
          planned_trip_part = trip.trip_parts.first # = FactoryGirl.create(:trip_part2)
          # puts services.ai
          services = eh.remove_ineligible_itineraries(planned_trip_part, services)
          # expect(    services.size).to eq 0
          expect(    services.size).to eq 3
        end

        it "is eligible for all five seeded services" do
          pending "todo"
          Time.zone = tz
          eh = EligibilityService.new
          characteristics = Characteristic.all
          characteristics.each do |c|
            if c.code == 'date_of_birth'
              UserCharacteristic.find_or_create_by_user_profile_id_and_characteristic_id(user_profile_id: @user_profile.id, characteristic_id: c.id, value: '05/11/1905')
            elsif c.code != 'age'
              UserCharacteristic.find_or_create_by_user_profile_id_and_characteristic_id(user_profile_id: @user_profile.id, characteristic_id: c.id, value: 'true')
            end
          end
          acc_and_eligible_services = eh.get_accommodating_and_eligible_services_for_traveler(user_profile)
          expect(acc_and_eligible_services.size).to eq 10
          planned_trip = FactoryGirl.create(:trip_part)
          purpose = TripPurpose.find_by_name('Medical')
          planned_trip.trip.trip_purpose = purpose
          services2 = eh.remove_ineligible_itineraries(planned_trip, acc_and_eligible_services)
          expect(services2.size).to eq 9
        end

        it "has 5 eligible services for the traveler and x for the trip" do
          pending "todo"
          Time.zone = tz
          eh = EligibilityService.new
          characteristics = Characteristic.all
          characteristics.each do |c|
            if c.code == 'date_of_birth'
              UserCharacteristic.find_or_create_by_user_profile_id_and_characteristic_id(user_profile_id: user_profile.id, characteristic_id: c.id, value: '05/11/1905')
            elsif c.code != 'age'
              UserCharacteristic.find_or_create_by_user_profile_id_and_characteristic_id(user_profile_id: user_profile.id, characteristic_id: c.id, value: 'true')
            end
          end
          services = eh.get_eligible_services_for_traveler(user_profile)
          expect(    services.size).to eq 10
          planned_trip = FactoryGirl.create(:trip_part)
          purpose = TripPurpose.find_by_name('Personal')
          planned_trip.trip.trip_purpose = purpose
          services = eh.remove_ineligible_itineraries(planned_trip, services)
          expect(    services.size).to eq 0
        end
      end

    end
  end