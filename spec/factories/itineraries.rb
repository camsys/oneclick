# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :itinerary do
    duration 1
    start_time "2013-07-08 14:59:26"
    end_time "2013-07-08 14:59:26"
    walk_time 1
    transit_time 1
    wait_time 1
    walk_distance 1.5
    transfers 1
    legs "MyString"
    cost "9.99"
  end
end
