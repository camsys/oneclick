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
            "question" => I18n.t('age_note'),
            "description" => I18n.t('age_desc'),
            "data_type" => 'integer',
            # "control_type" => 'foo',
            "options" => nil,
            "success_condition" => '>=65'
          }
        ]
      ]

    # just keeping this around for when we have a bool test
    options_for_bool = [
      {
        I18n.t(:yes_str) => true,
        I18n.t(:no_str) => false,
      }
    ]                    
  end

end

