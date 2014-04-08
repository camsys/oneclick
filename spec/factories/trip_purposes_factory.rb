FactoryGirl.define do
  
  factory :trip_purpose do
    sequence(:name) {|n| "Trip purpose #{n}"}
    sequence(:code) do |n|
      puts "In factory sequence, n is #{n}"
      "PURPOSE#{n}"
    end
  end

end
