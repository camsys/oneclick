require 'spec_helper'
# include MapHelper
# include TripsSupport

RESULT = [
  {:type=>"BUS",
   :logo_url=> Mode.transit.logo_url,
   :description=>"MARTA Bus Route 110 - Five Points To PEACHTREE ST NW@INTERNATIONAL BLVD",
   :start_time=>'2013-12-09T17:59:17-05:00',
   :end_time=>'2013-12-09T18:07:20-05:00',
   :start_place=>"33.774944,-84.384911",
   :end_place=>"33.759853,-84.387728"},
  {:type=>"WAIT",
   :description=>"Wait at PEACHTREE ST NW@INTERNATIONAL BLVD",
   :start_time=>'2013-12-09T18:07:21-05:00',
   :end_time=>'2013-12-09T18:17:19-05:00',
   :start_place=>"33.759853,-84.387728",
   :end_place=>"33.774944,-84.384911"},
  {:type=>"BUS",
   :logo_url=> Mode.transit.logo_url,
   :description=>"MARTA Bus Route 112 - Someplace Else To PEACHTREE ST NW@INTERNATIONAL BLVD",
   :start_time=>'2013-12-09T18:17:20-05:00',
   :end_time=>'2013-12-09T18:27:20-05:00',
   :start_place=>"33.774944,-84.384911",
   :end_place=>"33.759853,-84.387728"},
  {:type=>"BUS",
   :logo_url=> Mode.transit.logo_url,
   :description=>"MARTA Bus Route 113 - Yet Another Place To PEACHTREE ST NW@INTERNATIONAL BLVD",
   :start_time=>'2013-12-09T18:27:21-05:00',
   :end_time=>'2013-12-09T18:36:59-05:00',
   :start_place=>"33.774944,-84.384911",
   :end_place=>"33.759853,-84.387728"},
  {:type=>"WALK",
   :logo_url=> Mode.walk.logo_url,
   :description=>"Walk To Peachtree Center Avenue Northeast",
   :start_time=>'2013-12-09T18:37:00-05:00',
   :end_time=>'2013-12-09T18:47:00-05:00',
   :start_place=>"33.75984838609497,-84.38760450114215",
   :end_place=>"33.75906560016298,-84.38607220988743"}
]

describe ItinerarySerializer do

  it 'inserts wait segments in legs properly' do
    trip = create(:trip)
    itin = ItinerarySerializer.new(create(:itinerary))
    itin.legs.should eq RESULT
  end

end
