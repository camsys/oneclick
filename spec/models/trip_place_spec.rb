require 'spec_helper'

# TODO This JSON is duplicated in another spec 
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


describe TripPlace do

  it "should have an address" do
    place = FactoryGirl.build(:trip_place2)
    place.should be_valid
    place.raw_address.should_not be_nil
  end

  it "can be created from JSON" do
    place = TripPlace.new_from_trip_proxy_place(FROM_PLACE_OBJECT)
    place.should be_valid
  end

end
