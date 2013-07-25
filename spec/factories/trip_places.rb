# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :trip_place1, class: TripPlace do
    lat 33.89415
    lon -84.5463115
  end

  factory :trip_place2, class: TripPlace do
    lat 34.89415
    lon -84.9463115
  end

  factory :trip_place3, class: TripPlace do
    nongeocoded_address "100 Cambridge Park Drive, Cambridge, MA"
  end

end