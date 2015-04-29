# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :zone_fare do
    from_zone nil
    to_zone nil
    fare_structure nil
    rate 1.5
  end
end
