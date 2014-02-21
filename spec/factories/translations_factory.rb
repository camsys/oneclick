# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do

  factory :cms_snippet, class: Translation do
    key 'home-bottom-left_html'
    value "FG Snippet Text"
    locale :en
  end
end
