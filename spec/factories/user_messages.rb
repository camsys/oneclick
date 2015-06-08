# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_message do
    user nil
    message nil
    read false
  end
end
