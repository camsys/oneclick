I18n.locale='en'

FactoryGirl.define do
  factory :veteran_characteristic, class: 'Characteristic' do
    code 'veteran'
    name 'Veteran'
    note 'The traveler is a veteran'
    datatype 'bool'
    desc 'military veterans'
  end

  factory :ada_characteristic, class: 'Characteristic' do
    code 'ada_eligible'
    name 'Ada Eligible'
    note 'The traveler is a ada eligble'
    datatype 'bool'
  end

  factory :dob_characteristic, class: 'Characteristic' do
    characteristic_type 'personal_factor'
    code 'date_of_birth'
    name 'Date of Birth'
    note 'Date of Birth'
    datatype 'date'
  end

  factory :age_characteristic, class: 'Characteristic' do
    characteristic_type 'personal_factor'
    code 'age'
    name 'age_name'
    note 'age_note'
    datatype 'integer'
    desc 'age_desc'
  end

  factory :disabled_characteristic, class: 'Characteristic' do
    code 'disabled'
    name 'Disabled'
    note 'The traveler is temporarily or permanently disabled'
    datatype 'bool'
    desc 'persons with a disability'
  end

  factory :nemt_characteristic, class: 'Characteristic' do
    code 'nemt_eligible'
    name 'NEMT/Medicaid Eligible'
    note 'The traveler is a NEMT/Medicaid eligible.'
    datatype 'bool'
  end

  factory :veteran_characteristic_map, class: 'UserCharacteristic' do
    traveler_characteristic factory: :veteran_characteristic
    value 'true'
  end

  factory :ada_characteristic_map, class: 'UserCharacteristic' do
    traveler_characteristic factory: :ada_characteristic
    value 'true'
  end

  factory :dob_characteristic_map, class: 'UserCharacteristic' do
    traveler_characteristic factory: :dob_characteristic
    value '05/11/1905'
  end

  factory :disabled_characteristic_map, class: 'UserCharacteristic' do
    traveler_characteristic factory: :disabled_characteristic
    value 'true'
  end

  factory :nemt_characteristic_map, class: 'UserCharacteristic' do
    traveler_characteristic factory: :nemt_characteristic
    value 'true'
  end

end
