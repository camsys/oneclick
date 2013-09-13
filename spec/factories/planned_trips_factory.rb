# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :trip_with_places, class: 'PlannedTrip' do
    trip_datetime Time.new(2113,8,2,12,30,3)
    is_depart true
    trip_status_id 1
    trip {FactoryGirl.create(:trip)}
  end

  factory :trip_with_places2, class: 'PlannedTrip' do
    trip_datetime Time.new(2013,7,2,12,30,3)
    is_depart true
    trip_status_id 1
    trip {FactoryGirl.create(:trip)}
  end

end
