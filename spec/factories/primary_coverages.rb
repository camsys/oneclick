# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :primary_coverage do
    service_id 1
    recipe "MyString"
    geom ""
  end
end
