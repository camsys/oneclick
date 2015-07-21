# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :flat_fare do
    one_way_rate 1.5
    round_trip_rate 1.5
    fare_structure nil
  end
end
