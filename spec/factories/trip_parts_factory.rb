# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :trip_part, class: 'TripPart' do
    scheduled_date {Time.zone.local(2113,8,2,12,30,3)}
    scheduled_time {Time.zone.local(2113,8,2,12,30,3)}
    is_depart true
    # trip {FactoryGirl.create(:trip)}
    # from_trip_place {FactoryGirl.create(:trip_place1)}
    # to_trip_place {FactoryGirl.create(:trip_place2)}
    # trip
    from_trip_place
    to_trip_place
    add_attribute :sequence, "0"

    factory :trip_part2 do
      scheduled_date {Time.zone.local(2013,7,2,12,30,3)}
      scheduled_time {Time.zone.local(2013,7,2,12,30,3)}
      is_depart true
      # trip {FactoryGirl.create(:trip)}
    end

    # Targeting Part 1 of Multipart Monday Schedule
    factory :trip_part3 do
      scheduled_date {Time.zone.local(2016,12,12,8)}
      scheduled_time {Time.zone.local(2016,12,12,8)}
      is_depart true
    end

    # Targeting Part 2 of Multipart Monday Schedule
    factory :trip_part4 do
      scheduled_date {Time.zone.local(2016,12,12,18)}
      scheduled_time {Time.zone.local(2016,12,12,18)}
      is_depart true
    end

  end

end
