require 'spec_helper'
include ServiceAdapters::RideshareAdapter

describe ServiceAdapters::RideshareAdapter do
  it "should talk to the rideshare service" do
    here = double(raw: {}, lon: 0.0, lat: 1.1)    
    there = double(raw: {}, long: 2.2, lat: 3.3)    
    result = create_rideshare_query here, there, Time.now
    result.should include({"dest.city"=>"", "dest.country"=>"", "dest.county"=>"", 
      "dest.geocodeType"=>"Address", "dest.latLon.x"=>"", "dest.latLon.y"=>"", "dest.postalCode"=>"", 
      "dest.state"=>"", "dest.street"=>"", "orig.city"=>"", "orig.country"=>"", "orig.county"=>"", 
      "orig.geocodeType"=>"Address", "orig.latLon.x"=>"", "orig.latLon.y"=>"", "orig.postalCode"=>"", 
      "orig.state"=>"", "orig.street"=>"", "search"=>"search", "window"=>3, "windowOption"=>"hours"})
  end
end
