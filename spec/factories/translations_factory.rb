# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do

  factory :en_cms_snippet, class: Translation do
    key 'cms_snippet'
    value "FG Snippet Text"
    locale :en
  end

  factory :es_cms_snippet, class: Translation do
    key 'cms_snippet'
    value "FG Snippet Text"
    locale :es
  end
end
