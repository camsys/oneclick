require 'spec_helper'

describe "planning a trip", :type => :feature do
  before :each do
    FactoryGirl.create(:user)
    allow(Geocoder).to(receive(:search)) do |nongeocoded_address|
      [
        {
          'data' => {
            'geometry' => {
              'location' => {
                'lat' => 1.0,
                'lng' => 2.0
              }
              },
              'formatted_address' => 'returned formatted_address'
            }
          }
        ]
      end
  end

  it "creates a new trip" do
    pending "todo"
    test_itineraries = [{'legs'=>'example leg'}]
    trip_planner = double(TripPlanner,
      get_fixed_itineraries: [true,[]],
      get_taxi_itineraries: [false,[]],
      get_paratransit_itineraries: [false,[]],
      convert_itineraries: test_itineraries)
    TripPlanner.stub(:new).and_return(trip_planner)
    visit '/trips/new'
    within("#new_trip") do
      fill_in 'trip_from_place_attributes_nongeocoded_address', with: '730 w peachtree st, atlanta, ga'
      fill_in 'trip_to_place_attributes_nongeocoded_address', :with => 'georgia state capitol, atlanta, ga'
      fill_in 'trip_trip_date', with: (DateTime.now + 1).strftime('%m/%d/%Y')
      fill_in 'trip_trip_time', with: (DateTime.now + 1).strftime("%I:%M %p")
    end
    click_button 'Plan it'
    # TODO Supply more mocking to get this to actually present more reasonable result.
    # expect(page).to have_content 'From: 730 West Peachtree Street Northwest'
    expect(page).to have_content 'Trip created, but no valid trip options could be found'    
  end
end
