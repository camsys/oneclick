FactoryGirl.define do

  # NOTE Do not create TripPurposes with factory; they are seed data and
  # so will be put there by db:seeds
  
  # factory :trip_purpose do
  #   sequence(:name) {|n| "Trip purpose #{n}"}
  #   sequence(:code) do |n|
  #     puts "In factory sequence, n is #{n}"
  #     "PURPOSE#{n}"
  #   end
  # end

end
