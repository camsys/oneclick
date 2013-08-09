# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :buddy_relationship do
    buddy_id 1
    status "MyString"
    traveler_id 1
  end
end
