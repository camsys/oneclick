require 'spec_helper'

describe Trip do
  it "should be populated with itineraries" do
    trip = FactoryGirl.create(:trip)
    test_itineraries = [{'legs'=>'example leg'}]
    trip_planner = double(TripPlanner, get_fixed_itineraries: [true,[]], convert_itineraries: test_itineraries)
    TripPlanner.stub(:new).and_return(trip_planner)
    trip.create_itineraries
    trip.itineraries.should_not be_empty
    trip.itineraries.first.legs.should eq "example leg"
  end

  it "should have one itinerary with status=400 and an error message" do
    trip = FactoryGirl.create(:trip)
    mock_error = {'id'=>400,'msg'=>'This is a test error message.'}
    trip_planner = double(TripPlanner, get_fixed_itineraries: [false, mock_error])
    TripPlanner.stub(:new).and_return(trip_planner)
    trip.create_itineraries
    trip.itineraries.first.status.should eq 400
    trip.itineraries.first.message.should eq 'This is a test error message.'
    trip.itineraries.count.should eq 1
  end

  it "should respond to has_valid_itineraries correctly" do
    trip = FactoryGirl.create(:trip)
    mock_error = {'id'=>400,'msg'=>'This is a test error message.'}
    trip_planner = double(TripPlanner, get_fixed_itineraries: [false, mock_error])
    TripPlanner.stub(:new).and_return(trip_planner)
    trip.create_itineraries
    trip.should_not have_valid_itineraries
  end
end