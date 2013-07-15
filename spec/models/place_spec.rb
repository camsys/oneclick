require 'spec_helper'

describe Place do

  it "should have an address" do
    place = FactoryGirl.create(:place3)
    place.geocode
    place.address.should_not be_nil
  end

  it "should have a valid lat and lon" do
    place = FactoryGirl.create(:place3)
    place.geocode
    place.lat.should be > 42.35
    place.lat.should be < 43.5
    place.lon.should be < -71.0
    place.lon.should be > -71.5
  end

end