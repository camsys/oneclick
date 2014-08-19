require 'spec_helper'

describe EligibilityService do

  let(:eh) { EligibilityService.new }

  before(:each) do
    @user_profile = FactoryGirl.create(:user_profile)
    @service1 = FactoryGirl.create(:populated_service)
    @service2 = FactoryGirl.create(:populated_service)
    @restricted_service = FactoryGirl.create(:restricted_service)
  end

  it "generates the missing information structure" do
    options_for_bool = [
       { text: I18n.t(:yes_str), value: true },
       { text: I18n.t(:no_str), value: false }
    ]                    

    trip = FactoryGirl.create(:trip, trip_purpose: TripPurpose.find_by_name('Medical'))
    planned_trip_part = trip.trip_parts.first

    itineraries = eh.get_eligible_services_for_traveler(@user_profile, nil, :itinerary)
    missing_info = eh.get_eligible_services_for_traveler(@user_profile, nil, :missing_info)
    expect(itineraries.size).to eq 3
    s = itineraries.last
    s['missing_information_text'].should eq "persons 65 years or older\\n"
    missing_info.should eq [
      [],
      [],
      [
          {
            "question" => I18n.t(:ask_age, age: '65'),
            "data_type" => 'bool',
            # "control_type" => 'foo',
            "options" => options_for_bool,
            "success_condition"=>"== true",
            "group_id" => 0,
            "code" => "age",
            "year" => 1949
          }
        ]
      ]

  end

end

