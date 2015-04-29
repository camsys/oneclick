# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :mileage_fare do
    base_rate 1.5
    mileage_rate 1.5
    fare_structure nil
  end
end
