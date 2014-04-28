I18n.locale='en'

FactoryGirl.define do
  factory :wheelchair_accommodation, class: 'Accommodation' do
    name 'Wheelchair Accessible'
    note 'wheelchair note'
    datatype 'bool'
    active 1
  end

  factory :wheelchair_accommodation_requirement, class: 'UserAccommodation' do
    accommodation factory: :wheelchair_accommodation
  end

  factory :service_wheelchair_accommodation, class: 'ServiceAccommodation' do
    accommodation factory: :wheelchair_accommodation
    active 1
  end

end
