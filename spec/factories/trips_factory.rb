# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :trip do
    #trip_time "2:59 pm"
    #trip_date (Date.today + 2).strftime('%m/%d/%Y')
    #arrive_depart 'depart_at'
    #factory :trip_part do
    #  from_place FactoryGirl.create(:trip_place1)
    #  to_place FactoryGirl.create(:trip_place2)
    #end

    # user {FactoryGirl.create(:user2)}
    user

    after(:build) do |trip|
      trip_place1 = FactoryGirl.create(:trip_place1, sequence: 0)
      trip_place2 = FactoryGirl.create(:trip_place2, sequence: 1)
      trip.trip_places << trip_place1
      trip.trip_places << trip_place2
      trip.trip_parts << FactoryGirl.create(:trip_part, sequence: 0, from_trip_place: trip_place1, to_trip_place: trip_place2)
      trip.desired_modes << Mode.paratransit
      trip.desired_modes << Mode.transit
      trip.save!
    end

    factory :trip2 do |trip|
      after(:build) do |trip|
        trip.trip_places = []
        trip.trip_parts = []
        trip_place1 = FactoryGirl.create(:trip_place1, sequence: 0)
        trip_place2 = FactoryGirl.create(:trip_place2, sequence: 1)
        trip.trip_places << trip_place1
        trip.trip_places << trip_place2
        trip.trip_parts << FactoryGirl.create(:trip_part2, sequence: 0, from_trip_place: trip_place1, to_trip_place: trip_place2)
        trip.save!
      end
    end

    factory :trip3 do |trip|
      after(:build) do |trip|
        trip_place1 = FactoryGirl.create(:trip_place1, sequence: 0)
        trip_place2 = FactoryGirl.create(:trip_place2, sequence: 1)
        trip.trip_parts << FactoryGirl.create(:trip_part3, sequence: 0, from_trip_place: trip_place1, to_trip_place: trip_place2)
      end
    end

    factory :trip4 do |trip|
      after(:build) do |trip|
        trip_place1 = FactoryGirl.create(:trip_place1, sequence: 0)
        trip_place2 = FactoryGirl.create(:trip_place2, sequence: 1)
        trip.trip_parts << FactoryGirl.create(:trip_part4, sequence: 0, from_trip_place: trip_place1, to_trip_place: trip_place2)
      end
    end

    factory :trip_with_owner do
      association :owner, factory: :user_with_places
    end
    factory :round_trip, parent: :trip do
      after(:build) do |trip|
        trip.trip_parts << FactoryGirl.create(:trip_part2, sequence: 1, from_trip_place: trip.trip_places[1], to_trip_place: trip.trip_places[0], is_return_trip: true)
      end
    end
    factory :trip_with_selected_itineraries, parent: :round_trip do
      after (:build) do |trip|
        trip.outbound_part.itineraries << FactoryGirl.create(:pt_itinerary)
        trip.return_part.itineraries << FactoryGirl.create(:pt_itinerary)
      end
    end
  end
end
