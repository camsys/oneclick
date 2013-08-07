require 'spec_helper'

# TODO probably a better way to do this without cut-n-paste code.

describe Place do

  before(:each) do
    allow(Geocoder).to(receive(:search)) do |nongeocoded_address|
      [
        {
          'data' => {
            'geometry' => {
              'location' => {
                'lat'     => 42.39434139999999,
                'lng'    => -71.1449444,
              }
              },
              'formatted_address' => '100 Cambridge Park Drive, Cambridge, MA 02140, USA'
            }
          }
        ]
      end
    end

    describe TripPlace do
      it "should have an address" do
        place = FactoryGirl.create(:trip_place3)
        place.geocode
        place.address.should_not be_nil
      end

      it "should have a valid lat and lon" do
        place = FactoryGirl.create(:trip_place3)
        place.geocode
        place.lat.should be > 42.35
        place.lat.should be < 43.5
        place.lon.should be < -71.0
        place.lon.should be > -71.5
      end
    end

    describe UserPlace do
      it "should have an address" do
        place = FactoryGirl.create(:user_place3)
        place.geocode
        place.address.should_not be_nil
      end

      it "should have a valid lat and lon" do
        place = FactoryGirl.create(:user_place3)
        place.geocode
        place.lat.should be > 42.35
        place.lat.should be < 43.5
        place.lon.should be < -71.0
        place.lon.should be > -71.5
      end
    end
  end