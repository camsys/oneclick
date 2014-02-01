# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :agency_organization, class: 'Organization' do
    sequence(:name) {|n| "Agency Organization #{n}"}
    org_type Organization::TYPE_AGENCY
  end
  factory :provider_organization, class: 'Organization' do
    sequence(:name) {|n| "Provider Organization #{n}"}
    org_type Organization::TYPE_PROVIDER
  end
end
