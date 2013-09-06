# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :empty_user_profile, class: 'UserProfile' do      
  end

  factory :user_profile do
    after(:create) do |up|
      create(:wheelchair_accommodation_requirement, user_profile: up)
    end
  end
end
