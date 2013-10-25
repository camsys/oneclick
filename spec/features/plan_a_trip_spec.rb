require 'spec_helper'

describe "planning a trip", :type => :feature do
  before :each do
    @user = FactoryGirl.create(:user)
    allow(OneclickGeocoder).to(receive(:geocode)) do |nongeocoded_address|
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
      PlaceSearchingController.any_instance.stub(:get_cached_addresses).and_return({foo: 'bar'})
    end

    it "creates a new trip" do
      pending "to do"
      test_itineraries = [{'legs'=>'example leg'}]
      trip_planner = double(TripPlanner,
        get_fixed_itineraries: [true,[]],
        get_taxi_itineraries: [false,[]],
        get_paratransit_itineraries: [false,[]],
        convert_itineraries: test_itineraries)
      TripPlanner.stub(:new).and_return(trip_planner)
      visit "/users/#{@user.id}/trips/new"
      # save_and_open_page
      # Have to set hidden fields explicitly - see http://stackoverflow.com/a/10805128
      # This isn't a full test then really, bypasses the geocoding check
      find('#from_place_selected').set('730 w peachtree st, atlanta, ga')
      find('#from_place_selected_type').set('4')
      find('#to_place_selected').set('georgia state capitol, atlanta, ga')
      find('#to_place_selected_type').set('4')
      fill_in 'trip_proxy_trip_date', with: (DateTime.now + 1).strftime('%m/%d/%Y')
      fill_in 'trip_proxy_trip_time', with: (DateTime.now + 1).strftime("%-I:%M %p")
      click_button 'Plan it'
      # TODO Supply more mocking to get this to actually present more reasonable result.
      # expect(page).to have_content 'From: 730 West Peachtree Street Northwest'
      expect(page).to have_content 'Trip created, but no valid trip options could be found'    
    end
  end
