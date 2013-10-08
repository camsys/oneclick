require 'spec_helper'
include ServiceAdapters::RideshareAdapter

describe ServiceAdapters::RideshareAdapter do
  it "should talk to the rideshare service" do
    here = double(geocoding_raw: {}, lon: 0.0, lat: 1.1)    
    there = double(geocoding_raw: {}, long: 2.2, lat: 3.3)    
    result = create_rideshare_query here, there, Time.now
    result.should == 'foo'
  end
end
