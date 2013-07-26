# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_place1, class: UserPlace do
    lat 33.89415
    lon -84.5463115
  end

  factory :user_place2, class: UserPlace do
    lat 34.89415
    lon -84.9463115
  end

  factory :user_place3, class: UserPlace do
    nongeocoded_address "100 Cambridge Park Drive, Cambridge, MA"
  end

end