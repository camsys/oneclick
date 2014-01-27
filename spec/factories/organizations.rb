# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :agency_organization, class: 'Agency' do
    sequence(:name) {|n| "Agency Organization #{n}"}
  end
  factory :provider_organization, class: 'ProviderOrg' do
    sequence(:name) {|n| "Provider Organization #{n}"}
  end
end
