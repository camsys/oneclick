# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :property do
    category "MyString"
    name "MyString"
    value "MyString"
    sort_order 1
  end
end
