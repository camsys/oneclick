I18n.locale='en'

FactoryGirl.define do
  factory :wheelchair_accommodation, class: 'Accommodation' do
    name 'Wheelchair Accessible'
    note 'wheelchair note'
    datatype 'bool'
    active 1
  end

  factory :wheelchair_accommodation_requirement, class: 'UserAccommodation' do
    traveler_accommodation factory: :wheelchair_accommodation
    value 'true'
  end

  factory :service_wheelchair_accommodation, class: 'ServiceAccommodation' do
    traveler_accommodation factory: :wheelchair_accommodation
    value 'true'
    active 1
  end

end
