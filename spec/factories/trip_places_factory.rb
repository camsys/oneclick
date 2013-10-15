# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :trip_place1, class: TripPlace do
    raw_address 'bar'
    lat 33.89415
    lon -84.5463115
    zip '30308'
  end

  factory :trip_place2, class: TripPlace do

    raw_address '999 Peachtree street, Atlanta, GA'
    lat 33.781448
    lon -84.383959
    trip_id 1
    add_attribute :sequence, "1"
    county 'Fulton'

  end

  factory :trip_place3, class: TripPlace do

    raw_address 'Georgia State Capitol, Atlanta, GA'
    lat 33.749426
    lon -84.388117
    trip_id 1
    add_attribute :sequence, "2"

  end
end