# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :trip do
    trip_time "2:59 pm"
    trip_date (Date.today + 2).strftime('%m/%d/%Y')
    factory :trip_with_places do
      after(:create) do |t|
        t.places << FactoryGirl.create(:trip_place1)
        t.places << FactoryGirl.create(:trip_place2)
        t.save
      end
    end
  end
end