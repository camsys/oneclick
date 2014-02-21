FactoryGirl.define do
  factory :service, class: 'Service' do
    name 'Blank Service'
    provider
    service_type
  end

  factory :populated_service, class: 'Service' do
    name "Test Service"
    provider
    service_type
    after(:build) do |s|
      create(:eight_to_five_wednesday, service: s)
      create(:service_wheelchair_accommodation, service: s)
    end
  end
end
