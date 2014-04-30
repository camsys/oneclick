require 'spec_helper'

describe TripPlanner do

  it "should yield list of itinerary hashes" do
    t = TripPlanner.new
    mock_itineraries = [{'legs' => 'example legs', 'duration' => 1, 'startTime' => 1373393976000, 'endTime' => 1.0},
                   {'legs' => 'example legs', 'duration' => 2, 'startTime' => 1373393976000, 'endTime' => 1.0}]
    plan = {'itineraries' => mock_itineraries}
    count = 0
    itineraries = t.convert_itineraries(plan)
    itineraries.each do |itinerary|
      itinerary['legs'].should eq "--- example legs\n...\n"
      itinerary.should_not respond_to(:save)
      itinerary['start_time'].should eq Time.at(1373393976000/1000)
      count += 1
      itinerary['duration'].should eq count
    end
    count.should eq 2
  end

end
