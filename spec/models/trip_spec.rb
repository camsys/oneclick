require 'spec_helper'

describe Trip do
  describe "itineraries" do
    it "should be populated with itineraries" do
      trip = FactoryGirl.create(:trip_with_places)
      test_itineraries = [{'legs'=>'example leg'}]
      trip_planner = double(TripPlanner, get_fixed_itineraries: [true,[]], convert_itineraries: test_itineraries)
      TripPlanner.stub(:new).and_return(trip_planner)
      trip.create_itineraries
      trip.itineraries.should_not be_empty
      trip.itineraries.first.legs.should eq "example leg"
    end

    it "should have one itinerary with status=400 and an error message" do
      trip = FactoryGirl.create(:trip_with_places)
      mock_error = {'id'=>400,'msg'=>'This is a test error message.'}
      trip_planner = double(TripPlanner, get_fixed_itineraries: [false, mock_error])
      TripPlanner.stub(:new).and_return(trip_planner)
      trip.create_itineraries
      trip.itineraries.first.status.should eq 400
      trip.itineraries.first.message.should eq 'This is a test error message.'
      trip.itineraries.count.should eq 1
    end

    it "should respond to has_valid_itineraries correctly" do
      trip = FactoryGirl.create(:trip_with_places)
      mock_error = {'id'=>400,'msg'=>'This is a test error message.'}
      trip_planner = double(TripPlanner, get_fixed_itineraries: [false, mock_error])
      TripPlanner.stub(:new).and_return(trip_planner)
      trip.create_itineraries
      trip.should_not have_valid_itineraries
    end
  end

  it "should support nested attributes for places" do
    trip = Trip.create!(trip_date: (Date.today + 2).strftime('%m/%d/%Y'), trip_time: '2:59 pm',
      from_place_attributes: {nongeocoded_address: 'bar'})
    trip.from_place.nongeocoded_address.should eq 'bar'
  end
end