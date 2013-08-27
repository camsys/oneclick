# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :trip_with_places do
    trip_datetime Time.new(2013,8,3,12,30,3)
    is_depart true
    #from_place FactoryGirl.create(:trip_place2)
    #to_place FactoryGirl.create(:trip_place3)

 #   factory :trip_with_owner do
  #    association :owner, factory: :user_with_places
  #  end
  end
end
