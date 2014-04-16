FactoryGirl.define do
  
  factory :trip_purpose do
    sequence(:name) {|n| "Trip purpose #{n}"}
    sequence(:code) do |n|
      "PURPOSE#{n}"
    end
  end

end
