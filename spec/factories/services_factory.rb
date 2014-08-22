include EligibilityOperators
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
      create(:disabled, service: s)
      create(:veteran, service: s)
      contact = create(:service_contact, services: [s])
      contact.add_role :internal_contact, s
    end
  end

  factory :over_65, class: 'ServiceCharacteristic' do
    association :characteristic, factory: :age_characteristic
    value 65
    rel_code GE
    group 0
  end
  factory :disabled, class: 'ServiceCharacteristic' do
    association :characteristic, factory: :disabled_characteristic
    value true
    rel_code EQ
    group 1
  end
  factory :veteran, class: 'ServiceCharacteristic' do
    association :characteristic, factory: :veteran_characteristic
    value true
    rel_code EQ
    group 1
  end
end
