require 'spec_helper'

describe TripPlace do

  it "should have an address" do
   place = FactoryGirl.build(:trip_place2)
   place.raw_address.should_not be_nil
 end

end
