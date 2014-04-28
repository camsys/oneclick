require 'spec_helper'

# TODO This JSON is duplicated in another spec 
FROM_PLACE_OBJECT_POI = <<EOF
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

FROM_PLACE_OBJECT_AUTOCOMPLETE = <<EOF
{
  "index": 0,
  "type": "5",
  "type_name": "PLACES_AUTOCOMPLETE_TYPE",
  "name": "730 Peachtree Street Northeast, Atlanta, GA, United States",
  "id": "CnRoAAAALT2S6a6w2o0Szna-Tkt__c5wTXlx8-BlEnkfAzKvX9OyY3q_dJg8HaJc7aDiRlbS8xc5CgnG8hieFP4eSsNslc_RYcPUAGzmDd3qUE1fTJc06QAG7FTiDSIzfjXg3cIZ-_4EA_QvIh7PQmLFGEobxxIQvwRKEfPTJX6V7EwDeL2aVhoUN2FVCpV2blzkr03QnJT9vjIRjIg",
  "lat": null,
  "lon": null,
  "address": "730 Peachtree Street Northeast, Atlanta, GA, United States",
  "description": "(not rendered)"
}
EOF

describe TripPlace do

  it "should have an address" do
    place = FactoryGirl.build(:trip_place2)
    place.should be_valid
    place.raw_address.should_not be_nil
  end

  it "can be created from POI JSON" do
    place = TripPlace.new.from_trip_proxy_place(FROM_PLACE_OBJECT_POI, 0)
    place.should be_valid
  end

  it "can be created from GOOGLE JSON" do
    place = TripPlace.new.from_trip_proxy_place(FROM_PLACE_OBJECT_AUTOCOMPLETE, 0)
    place.should be_valid
  end

  it "can have a name and prefers that to address" do
    p = TripPlace.new(address1: '1 Main St', city: 'Atlanta', state: 'GA')
    p.name.should eq '1 Main St, Atlanta, GA ' # note trailing blank
    p.name = 'Goodwill Atlanta'
    p.name.should eq 'Goodwill Atlanta'
  end

  it "defaults to the address if it does not have name" do
    
  end

end
