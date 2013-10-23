require 'spec_helper'

describe Trip do
 describe "itineraries" do
  it "should be populated with itineraries" do
    pending "todo"      
    planned_trip = FactoryGirl.create(:trip_with_places)
    test_itineraries = [{'legs'=>'example leg'}]
    trip_planner = double(TripPlanner,
      get_fixed_itineraries: [true,[]],
      get_taxi_itineraries: [false,[]],
      get_paratransit_itineraries: [false,[]],
      get_rideshare_itineraries: [false,[]],
      convert_itineraries: test_itineraries)
    TripPlanner.stub(:new).and_return(trip_planner)
    planned_trip.create_itineraries
    planned_trip.itineraries.should_not be_empty
    planned_trip.itineraries.first.legs.should eq "example leg"
  end

  it "should have one itinerary with status=400 and an error message" do
    pending "todo"      
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
        pending "todo"      
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
      pending "todo"      
      trip = Trip.create!(trip_date: (Date.today + 2).strftime('%m/%d/%Y'), trip_time: '2:59 pm',
        places_attributes: [{nongeocoded_address: 'bar', sequence: 0}, {nongeocoded_address: 'baz', sequence: 1}]
        )
      trip.reload
      trip.places[0].nongeocoded_address.should eq 'bar'
      trip.places[1].nongeocoded_address.should eq 'baz'
      trip.from_place.nongeocoded_address.should eq 'bar'
      trip.to_place.nongeocoded_address.should eq 'baz'
    end
    it "should support from_place and to_place aliases for places for now" do
      pending "todo"      
      trip = Trip.create!(trip_date: (Date.today + 2).strftime('%m/%d/%Y'), trip_time: '2:59 pm',
        from_place_attributes: {nongeocoded_address: 'bar', sequence: 0}, to_place_attributes: {nongeocoded_address: 'baz', sequence: 1}
        )
      trip.reload
      trip.from_place.nongeocoded_address.should eq 'bar'
      trip.to_place.nongeocoded_address.should eq 'baz'
      trip.places[0].nongeocoded_address.should eq 'bar'
      trip.places[1].nongeocoded_address.should eq 'baz'
    end
    it "should have from_place and to_place aliases even when comes from db" do
      pending "todo"      
      trip = FactoryGirl.create(:trip_with_places,
        from_place_attributes: {sequence: 0, nongeocoded_address: 'bar'}, to_place_attributes: {sequence: 1, nongeocoded_address: 'baz'}
        )
      db_trip = Trip.find(trip.id)
      db_trip.from_place.nongeocoded_address.should eq 'bar'
      db_trip.to_place.nongeocoded_address.should eq 'baz'
    end
    it "should handle places that come from the user" do
      pending "todo"      
      trip = FactoryGirl.build(:trip_with_owner)
      trip.from_place = TripPlace.new({sequence: 0, nongeocoded_address: trip.owner.places[0].name})
      trip.to_place = TripPlace.new({sequence: 1, nongeocoded_address: trip.owner.places[1].name})
      trip.save!
      trip.from_place.nongeocoded_address.should eq 'bar'
      db_trip = Trip.find(trip.id)
      db_trip.from_place.nongeocoded_address.should eq 'bar'
      db_trip.to_place.nongeocoded_address.should eq 'baz'
    end

    describe "date and time validation" do
      it "should reject a past date" do
        pending "todo"      
        trip = Trip.new
        trip.trip_datetime = Date.today - 1
        trip.datetime_cannot_be_before_now.should be_false
        trip.errors.size.should eq 1
        trip.errors.first.should eq [:trip_date, "Trips cannot be entered for days earlier than today."]
      end
      it "should reject a time today that is before current time" do
        pending "todo"      
        trip = Trip.new
        trip.trip_datetime = Time.current - 60
        trip.datetime_cannot_be_before_now.should be_false
        trip.errors.size.should eq 1
        trip.errors.first.should eq [:trip_time, "Trips cannot be entered for past times."]
      end
      it "should accept a time today that is after current time" do
        pending "todo"      
        trip = Trip.new
        trip.trip_datetime = Time.current + 60
        trip.datetime_cannot_be_before_now.should be_true
        trip.errors.size.should eq 0
      end
      it "should accept a time tomorrow that is before the current time of day" do
        pending "todo"      
        trip = Trip.new
        trip.trip_datetime = Time.current + (60*60*23)
        trip.datetime_cannot_be_before_now.should be_true
        trip.errors.size.should eq 0
      end
      it "should reject a past date set via trip_date and _time" do
        pending "todo"      
        trip = Trip.new
        trip.trip_date = (Date.today - 1).strftime("%m/%d/%Y")
        trip.trip_time = "9:06 am"
        trip.validate_date_and_time
        trip.datetime_cannot_be_before_now.should be_false
        trip.errors.size.should eq 1
        trip.errors.first.should eq [:trip_date, "Trips cannot be entered for days earlier than today."]
      end
    end

    describe "write_trip_datetime" do
      it "handles near future datetime" do
        pending "todo"      
        trip = Trip.new
        d = DateTime.current
        trip.trip_date = d.strftime("%m/%d/%Y")
        trip.trip_time = (d + 60*60).strftime("%H:%M %p")
        trip.write_trip_datetime.should be_true
        trip.trip_datetime.strftime("%m/%d/%Y %H:%M %p %z").should eq d.strftime("%m/%d/%Y %H:%M %p %z")
      end
      
      it "handles extraneous spaces" do
        pending "todo"      
        trip = Trip.new
        d = DateTime.current
        trip.trip_date = d.strftime("%m/%d/%Y  ")
        trip.trip_time = (d + 60*60).strftime("%H:%M   %p")
        trip.write_trip_datetime.should be_true
        trip.trip_datetime.strftime("%m/%d/%Y %H:%M %p %z").should eq d.strftime("%m/%d/%Y %H:%M %p %z")
      end
      
    end
  end
