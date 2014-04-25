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
      contact = create(:service_contact, services: [s])
      contact.add_role :internal_contact, s
    end
  end

  factory :restricted_service, class: 'Service' do
    name "Restricted Service"
    provider
    service_type
    after(:build) do |s|
      create(:eight_to_five_wednesday, service: s)
      create(:over_65, service: s)
      contact = create(:service_contact, service: s)
      contact.add_role :internal_contact, s
    end
  end

  factory :over_65, class: 'ServiceCharacteristic' do
    association :characteristic, factory: :age_characteristic
    value 65
    value_relationship_id 4
  end
end
