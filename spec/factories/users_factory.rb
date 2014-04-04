# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  sequence :email do |n|
    "email#{n}@factory.com"
  end
  sequence :agency_email do |n|
    "email#{n}@agency.com"
  end
  sequence :agent_email do |n|
    "agent#{n}@agency.com"
  end

  factory :user do
    first_name 'Test'
    last_name 'User'
    email
    password 'changeme'
    password_confirmation 'changeme'
    # required if the Devise Confirmable module is used
    # confirmed_at Time.now
    factory :user_with_places do
      first_name 'WithPlaces'
      after(:create) do |u|
        u.places << FactoryGirl.create(:user_place1)
        u.places << FactoryGirl.create(:user_place2)
        u.save
      end
    end
    factory :user2 do
      first_name 'Test2'
      last_name 'User'
      email 'example2@example.com'
    end
    factory :spanish_user do
      first_name 'Spanish'
      last_name 'user'
      preferred_locale 'es'
    end
    factory :admin do
      first_name 'System'
      last_name 'admin'
      email 'admin@example.com'
      after(:create) do |u|
        u.add_role :system_administrator
        u.save
      end
    end
    factory :agency_admin do
      first_name 'Agency'
      last_name 'Administrator'
      email { generate(:agency_email) }
      agency FactoryGirl.create :arc_mobility_mgmt_agency
      after(:create) do |u|
        u.add_role :agency_administrator
        u.save!
      end
    end
    factory :agency_agent do
      first_name 'Agency'
      last_name 'Agent'
      email { generate(:agent_email) }
      agency FactoryGirl.create :arc_mobility_mgmt_agency
      after(:create) do |u|
        u.add_role :agent
        u.save!
      end
    end
  end
end
