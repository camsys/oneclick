FactoryGirl.define do
  factory :service, class: 'Service' do
    name 'Blank Service'
    provider
    service_type
  end

  factory :populated_service, class: 'Service' do
    after(:create) do |s|
      create(:eight_to_five_wednesday, service: s)
      create(:service_wheelchair_accommodation, service: s)
    end
    name "Test Service"
    provider_id 1
    service_type_id 1

  end
end
