require 'spec_helper'
# include MapHelper
include TripsSupport

describe TripsController do

  describe "GET /place_search.json?no_map_partial=true&query=f" do
    it "does right thing" do
      pending "See https://www.pivotaltracker.com/story/show/68068948"
      @traveler = double()
      mock_prediction = {
        'description' =>  'mock description',
        'reference' => 'mock reference'
      }

      mock_google_api = double(
        get: double(
          body: {'predictions' => [mock_prediction]},
          status: 200
          )
        )
      PlaceSearchingController.any_instance.stub(:google_api).and_return(mock_google_api)

      # # TODO This should go into a factory
      mock_poi = Poi.new address1: 'address1', city: 'Santa Cruz', state: 'CA',
        zip: '95060'
      Poi.should_receive(:get_by_query_str).and_return [mock_poi]

      get :search, no_map_partial: 'true', query: 'carter', format: :json

      j = JSON.parse(response.body)
      j.size.should eq 2
      f = j[0]
      f['full_address'].should eq "address1, Santa Cruz, CA 95060"
      f['type_name'].should eq "POI_TYPE"
      f = j[1]
      f['description'].should eq '(not rendered)'
      # TODO is this correct?
      f['reference'].should be_nil
    end
  end  

end
