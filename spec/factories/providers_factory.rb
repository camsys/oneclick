FactoryGirl.define do
  factory :provider do
    sequence(:name) {|n| "Provider #{n}"}
  end
end
