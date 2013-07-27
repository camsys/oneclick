require 'spec_helper'

describe Trip do
  before(:each) do
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

    describe "itineraries" do
      it "should be populated with itineraries" do
        trip = FactoryGirl.create(:trip_with_places)
        test_itineraries = [{'legs'=>'example leg'}]
        trip_planner = double(TripPlanner,
          get_fixed_itineraries: [true,[]],
          get_taxi_itineraries: [false,[]],
          get_paratransit_itineraries: [false,[]],
          convert_itineraries: test_itineraries)
        TripPlanner.stub(:new).and_return(trip_planner)
        trip.create_itineraries
        trip.itineraries.should_not be_empty
        trip.itineraries.first.legs.should eq "example leg"
      end

      it "should have one itinerary with status=400 and an error message" do
        trip = FactoryGirl.create(:trip_with_places)
        mock_error = {'id'=>400,'msg'=>'This is a test error message.'}
        trip_planner = double(TripPlanner, get_fixed_itineraries: [false, mock_error],
          get_taxi_itineraries: [false, mock_error],
          get_paratransit_itineraries: [false,[]],
          )
        TripPlanner.stub(:new).and_return(trip_planner)
        trip.create_itineraries
        trip.itineraries.first.status.should eq 400
        trip.itineraries.first.message.should eq 'This is a test error message.'
        # TODO Not sure if 3 is right here, the test is returning 3, wo with mode nil
        # and one with mode paratransit
        trip.itineraries.count.should eq 3
      end

      it "should respond to has_valid_itineraries correctly" do
        trip = FactoryGirl.create(:trip_with_places)
        mock_error = {'id'=>400,'msg'=>'This is a test error message.'}
        trip_planner = double(TripPlanner, get_fixed_itineraries: [false, mock_error],
          get_taxi_itineraries: [false, mock_error],
          get_paratransit_itineraries: [false, mock_error],
          )
        TripPlanner.stub(:new).and_return(trip_planner)
        trip.create_itineraries
        trip.should_not have_valid_itineraries
      end
    end

    it "should support nested attributes for places" do
      trip = Trip.create(trip_date: (Date.today + 2).strftime('%m/%d/%Y'), trip_time: '2:59 pm',
        places_attributes: [{nongeocoded_address: 'bar'}, {nongeocoded_address: 'baz'}]
        )
      trip.places[0].nongeocoded_address.should eq 'bar'
      trip.places[1].nongeocoded_address.should eq 'baz'
    end
    it "should from_place and to_place aliases for places for now" do
      trip = Trip.create(trip_date: (Date.today + 2).strftime('%m/%d/%Y'), trip_time: '2:59 pm',
        from_place: {nongeocoded_address: 'bar'}, to_place: {nongeocoded_address: 'baz'}
        )
      trip.from_place.nongeocoded_address.should eq 'bar'
      trip.to_place.nongeocoded_address.should eq 'baz'
    end
    it "should have from_place and to_place aliases even when comes from db" do
      trip = FactoryGirl.create(:trip_with_places)
      db_trip = Trip.find(trip.id)
      db_trip.from_place.nongeocoded_address.should eq 'bar'
      db_trip.to_place.nongeocoded_address.should eq 'baz'
    end
  end
