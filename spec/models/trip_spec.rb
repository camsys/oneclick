require 'spec_helper'
include TripsSupport

FROM_PLACE_OBJECT = <<EOF
{
  "index": 0,
  "type": "1",
  "type_name": "POI_TYPE",
  "description": "(notrendered)",
  "full_address": "386PineStreet, NE, Atlanta, GA 30308",
  "id": 480,
  "poi_type_id": 1,
  "name": "C. W. Hill Elementary School",
  "address1": "386 Pine Street, NE",
  "city": "Atlanta",
  "state": "GA",
  "zip": "30308",
  "lat": 33.76768484,
  "lon": -84.37445815,
  "county": "Fulton"
}
EOF

TO_PLACE_OBJECT = <<EOF
{
  "index": 0,
  "type": "1",
  "type_name": "POI_TYPE",
  "description": "(not rendered)",
  "full_address": "970 Martin Street, SE, Atlanta, GA 30315",
  "id": 476,
  "poi_type_id": 1,
  "name": "D. H. Stanton Elementary School",
  "address1": "970 Martin Street, SE",
  "city": "Atlanta",
  "state": "GA",
  "zip": "30315",
  "lat": 33.72795091,
  "lon": -84.38327011,
  "county": "Fulton"
}
EOF

describe Trip do
  describe "itineraries" do
    it "should be populated with itineraries" do
      trip = FactoryGirl.create(:trip)
      legs = test_legs
      test_itineraries = [{'mode'=>Mode.new(name: 'TRANSIT', active: true), 'legs'=>legs}]
      trip_planner = double(TripPlanner,
        get_fixed_itineraries: [true,[]],
        get_taxi_itineraries: [false,['Test does not implement get_taxi_itineraries']],
        get_paratransit_itineraries: [false,['Test does not implement get_paratransit_itineraries']],
        get_rideshare_itineraries: [false,['Test does not implement get_rideshare_itineraries']],
        convert_itineraries: test_itineraries)

      eligibilility_helpers = double(EligibilityHelpers,
        get_accommodating_and_eligible_services_for_traveler: [],
        get_eligible_services_for_trip: [])

      TripPlanner.stub(:new).and_return(trip_planner)
      EligibilityHelpers.stub(:new).and_return(eligibilility_helpers)
      trip.create_itineraries
      trip.itineraries.should_not be_empty
      trip.itineraries.first.legs.should eq legs
    end

    it "should have one itinerary with status=400 and an error message" do
      pending "todo"      
      trip = FactoryGirl.create(:trip)
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
      trip = FactoryGirl.create(:trip)
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
    trip = FactoryGirl.create(:trip,
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

  it "should convert a trip proxy to a trip" do
    FactoryGirl.create(:trip_purpose)
    tomorrow = Date.tomorrow
    trip_time = Time.now + 1.hour
    return_trip_time = Time.now + 2.hours
    tp = TripProxy.new(
      "mode"=>"1",
      "from_place_object" => FROM_PLACE_OBJECT,
      "to_place_object" => TO_PLACE_OBJECT,
      "from_place" => "C. W. Hill Elementary School",
      "to_place" => "D. H. Stanton Elementary School",
      "trip_date"=>"#{tomorrow.strftime("%m/%d/%Y")}",
      "arrive_depart"=>"Departing At",
      "trip_time"=>"#{trip_time.strftime("%H:%M")}",
      "trip_purpose_id"=>"#{TripPurpose.first.id}",
      "is_round_trip"=>"1",
      "return_trip_time"=>"#{return_trip_time.strftime("%H:%M")}"
      )

    u = FactoryGirl.create(:user)
    t = Trip.create_from_proxy(tp, u, u)
    t.save
    t.trip_datetime.to_s.should eq (tomorrow.strftime + "T" + trip_time.strftime("%H:%M") + ":00+00:00")
    t.trip_parts.size.should eq 2
    t.trip_parts.each do |tp|
      tp.should be_valid
    end
    t.trip_places.size.should eq 2
    t.trip_places.each do |tp|
      tp.should be_valid
    end
    t.should be_valid
  end


end
