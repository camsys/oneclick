# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :rating do
    association :rateable, :factory => :arc_agency
    value 3
    comments "decent"
  end
end
