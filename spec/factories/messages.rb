# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :message do
    body "MyText"
    from_date "2015-06-08 17:08:27"
    to_date "2015-06-08 17:08:27"
  end
end
