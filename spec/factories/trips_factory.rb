# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :trip do
    #trip_time "2:59 pm"
    #trip_date (Date.today + 2).strftime('%m/%d/%Y')
    #arrive_depart 'depart_at'
    #factory :trip_with_places do
    #  from_place FactoryGirl.create(:trip_place1)
    #  to_place FactoryGirl.create(:trip_place2)
    #end
    after(:create) do |trip|
      trip.trip_places << FactoryGirl.build(:trip_place1, sequence: 0)
      trip.trip_places << FactoryGirl.build(:trip_place2, sequence: 0)
      trip.save!
    end
    factory :trip_with_owner do
      association :owner, factory: :user_with_places
    end
  end
end
