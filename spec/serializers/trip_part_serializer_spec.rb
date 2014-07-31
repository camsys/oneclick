require 'spec_helper'
# include MapHelper
# include TripsSupport

describe TripPartSerializer do

  describe 'what it does' do
    it 'has a description' do
      trip = create(:trip)
      tps = TripPartSerializer.new(trip.trip_parts.first)
      tps.description.should eq 'Outbound - 1670 Clairmont Rd Decatur, GA 30033 to 999 West Peachtree St NW Atlanta, GA 30309'
    end
  end

end

