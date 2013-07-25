# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :trip do
    trip_time "2:59 pm"
    trip_date (Date.today + 2).strftime('%m/%d/%Y')
    association :from_place, factory: :place1
    association :to_place, factory: :place2

  end
end