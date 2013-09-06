I18n.locale='en'

FactoryGirl.define do
  factory :wheelchair_accommodation, class: 'TravelerAccommodation' do
    name 'Wheelchair Accessible'
    note 'wheelchair note'
    datatype 'bool'
  end

  factory :wheelchair_accommodation_requirement, class: 'UserTravelerAccommodationsMap' do
    traveler_accommodation factory: :wheelchair_accommodation
    value 'true'
  end


end
