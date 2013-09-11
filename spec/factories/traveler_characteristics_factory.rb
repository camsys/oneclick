I18n.locale='en'

FactoryGirl.define do
  factory :veteran_characteristic, class: 'TravelerCharacteristic' do
    code 'veteran'
    name 'Veteran'
    note 'The traveler is a veteran'
    datatype 'bool'
  end

  factory :veteran_characteristic_map, class: 'UserTravelerCharacteristicsMap' do
    traveler_characteristic factory: :veteran_characteristic
    value 'true'
  end

end
