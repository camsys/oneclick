require 'spec_helper'

describe EligibilityService do

  let(:eh) { EligibilityService.new }

  before(:each) do
    @user_profile = FactoryGirl.create(:user_profile)
    # These services needed to be created so they get applied to the itinerary
    @service1 = FactoryGirl.create(:populated_service)
    @service2 = FactoryGirl.create(:populated_service)
    @restricted_service = FactoryGirl.create(:restricted_service)
  end


# Group1 Disabled
# Group1 Red Hair
# Group2 Age > 50
# is (Disabled And Red Hair) or (Age > 50)

  it "generates the missing information structure" do
    options_for_bool = [
       { text: I18n.t(:yes_str), value: true },
       { text: I18n.t(:no_str), value: false }
    ]

    trip = FactoryGirl.create(:trip, trip_purpose: TripPurpose.find_by_name('Medical'))
    planned_trip_part = trip.trip_parts.first

    missing_info = eh.get_eligible_services_for_traveler(@user_profile, nil, :missing_info)
    missing_info.should eq [
      [],
      [],
      [
        {"question"=>"Are you age 65 or older?", "data_type"=>"bool", "options"=>[{:text=>"Yes", :value=>true}, {:text=>"No", :value=>false}], "success_condition"=>"== true", "group_id"=>0, "code"=>"age", "year"=>"65"},
        {"question"=>"translation missing: en.The traveler is temporarily or permanently disabled", "data_type"=>"bool", "options"=>[{:text=>"Yes", :value=>true}, {:text=>"No", :value=>false}], "success_condition"=>"==t", "group_id"=>1, "code"=>"disabled", "year"=>"t"},
        {"question"=>"translation missing: en.The traveler is a veteran", "data_type"=>"bool", "options"=>[{:text=>"Yes", :value=>true}, {:text=>"No", :value=>false}], "success_condition"=>"==t", "group_id"=>1, "code"=>"veteran", "year"=>"t"}
      ]
    ]
  end

  it "generates the missing information string" do
    trip = FactoryGirl.create(:trip, trip_purpose: TripPurpose.find_by_name('Medical'))
    planned_trip_part = trip.trip_parts.first

    itineraries = eh.get_eligible_services_for_traveler(@user_profile, nil, :itinerary)
    expect(itineraries.size).to eq 3
    s = itineraries.last
    service = s['service']
    s['missing_information_text'].should eq "age_min65:disabled_missing_info,veteran_missing_info"
  end

end

