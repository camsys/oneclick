I18n.locale='en'

FactoryGirl.define do
  factory :wheelchair_accommodation, class: 'TravelerAccommodation' do
    name 'Wheelchair Accessible'
    note 'wheelchair note'
    datatype 'bool'
    active 1
  end

  factory :wheelchair_accommodation_requirement, class: 'UserTravelerAccommodationsMap' do
    traveler_accommodation factory: :wheelchair_accommodation
    value 'true'
  end

  factory :service_wheelchair_accommodation, class: 'ServiceTravelerAccommodationsMap' do
    traveler_accommodation factory: :wheelchair_accommodation
    value 'true'
    active 1
  end

end
