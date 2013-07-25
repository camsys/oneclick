require 'spec_helper'

# TODO probably a better way to do this without cut-n-paste code.

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