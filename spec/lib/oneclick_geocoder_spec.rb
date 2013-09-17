require 'spec_helper'
# require 'oneclick_geocoder'
# require 'geocoder'

describe OneclickGeocoder do
  before(:each) do
    mock_result = double(
      types: ['street_address'],
      formatted_address: '1 Main St, Atlanta, GA, USA',
      address: '1 Main St, Atlanta, GA, USA',
      city: 'Atlanta',
      state_code: 'GA',
      postal_code: '99999',
      latitude: 1.0,
      longitude: 2.0
      )
    # mock_results = double(each: [mock_result])
    mock_results = double('results')
    allow(mock_results).to receive(:each).and_yield mock_result
    Geocoder.stub(:search).and_return mock_results
  end
  it "is usable returning one value" do
    o_geocoder = OneclickGeocoder.new
    status = o_geocoder.geocode 'a fake address'
    status.should be_true
    result = o_geocoder.results
    result.should eq [{:id=>0, :name=>"1 Main St", :formatted_address=>"1 Main St, Atlanta, GA", 
      :street_address=>"1 Main St, Atlanta, GA", :city=>"Atlanta", :state=>"GA", :zip=>"99999", :lat=>1.0, :lon=>2.0}]
  end
  it "is usable returning two values" do
    o_geocoder = OneclickGeocoder.new
    status, g_errors, result = o_geocoder.geocode 'a fake address'
    status.should be_true    
    result.should eq [{:id=>0, :name=>"1 Main St", :formatted_address=>"1 Main St, Atlanta, GA",
      :street_address=>"1 Main St, Atlanta, GA", :city=>"Atlanta", :state=>"GA", :zip=>"99999", :lat=>1.0, :lon=>2.0}]
  end
end
