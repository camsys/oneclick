require 'spec_helper'
include MapHelper

describe TripsController do
  before :each do
    @helper = Object.new.extend MapHelper
  end
  it 'should handle a long list of geocoded results' do
    pending 'See https://www.pivotaltracker.com/story/show/62235678'
    @helper.stub(:get_addr_marker).and_return 'return from get_addr_marker'
    OneclickGeocoder.any_instance.stub(:results).and_return(
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
      )
    #
    request.env["HTTP_ACCEPT"] = 'application/json'
    post 'geocode', user_id: FactoryGirl.create(:user)
    response.body.should eq 'foo'    
  end

end
