# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :place1, class: Place do
    lat 33.89415
    lon -84.5463115
  end

  factory :place2, class: Place do
    lat 34.89415
    lon -84.9463115
  end
end