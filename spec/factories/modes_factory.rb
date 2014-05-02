FactoryGirl.define do
  factory :mode do
    name "Paratransit"
    code "mode_paratransit"
    active true
  end
  factory :mode_paratransit, class: Mode do
    name "Paratransit"
    code "mode_paratransit"
    active true
  end
  factory :mode_fixed, class: Mode do
    name "Transit"
    code "mode_transit"
    active true
  end
end