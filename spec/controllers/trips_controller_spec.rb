require 'spec_helper'
# include MapHelper
include TripsSupport

describe TripsController do

  describe 'shows' do
    it 'returns a trip as JSON' do
      pending "Filtering broke this, get it in release 6" # TODO
      service1 = FactoryGirl.create(:populated_service)
      service2 = FactoryGirl.create(:populated_service)
      restricted_service = FactoryGirl.create(:restricted_service)
      itin1 = FactoryGirl.create(:itinerary, service: service1)
      itin2 = FactoryGirl.create(:itinerary, service: service2)
      itin3 = FactoryGirl.create(:itinerary, service: restricted_service)
      user = FactoryGirl.create(:user)
      sign_in user

      trip = FactoryGirl.create(:trip, trip_purpose: TripPurpose.find_by_name('Medical'), user: user)
      trip_part = create(:trip_part)
      trip_part.itineraries << itin1
      trip_part.itineraries << itin2
      trip_part.itineraries << itin3
      trip.trip_parts << trip_part

      get :show, user_id: user.id, id: trip.id, format: :json
      j = JSON.parse(response.body)

      # puts j.ai

      t = HashWithIndifferentAccess.new(j)
      t[:status].should eq 1
      t[:trip_parts].size.should eq 2
      tp = t[:trip_parts][1]
      tp[:description].should eq "Outbound - 999 West Peachtree St NW Atlanta, GA 30309 to 206 Washington St SW Atlanta, GA 30334"
      tp[:is_depart_at].should be_true
      tp[:start_time].should eq "2113-08-02T12:30:03.000-05:00"
      tp[:itineraries].size.should eq 3
      i = tp[:itineraries][2]
      i[:mode].should eq 'mode_paratransit'
      i[:mode_name].should eq 'Specialized Services'
      mi = i[:missing_information][0]
      mi[:question].should eq "What is your birth year?"
      mi[:data_type].should eq "integer"
      mi[:options].should eq nil
      mi[:success_condition].should eq ">=65"
      # TODO check more components
    end
  end

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
