# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :trip_place1, class: TripPlace do
    raw_address 'Atlanta VA Medical Center, 1670 Clairmont Rd, Decatur, GA 30033'
    address1 "1670 Clairmont Rd"
    city "Decatur"
    state "GA"
    zip "30033"
    county 'DeKalb'
    # TODO I do not know if this lat/lon is right
    lat 33.89415
    lon -84.5463115
    # trip {FactoryGirl.create(:trip)}
    # trip
  end

  factory :trip_place2, class: TripPlace do
    raw_address '999 West Peachtree St NW, Atlanta, GA 30309'
    address1 "999 West Peachtree St NW"
    city "Atlanta"
    state "GA"
    zip "30309"
    county 'Fulton'
    # TODO I do not know if this lat/lon is right
    lat 33.781448
    lon -84.383959
    # trip_id 1
    # trip {FactoryGirl.create(:trip)}
    # trip
    add_attribute :sequence, "1"

    factory :from_trip_place do
      add_attribute :sequence, "0"
    end
      
  end

  factory :trip_place3, class: TripPlace do

    raw_address 'Georgia State Capitol, Atlanta, GA'
    address1 "206 Washington St SW"
    city "Atlanta"
    state "GA"
    zip "30334"
    county 'Fulton'
    # TODO I do not know if this lat/lon is right
    lat 33.749426
    lon -84.388117
    # trip_id 1
    # trip {FactoryGirl.create(:trip)}
    # trip
    add_attribute :sequence, "2"

    factory :to_trip_place do
      add_attribute :sequence, "1"
    end

  end
end