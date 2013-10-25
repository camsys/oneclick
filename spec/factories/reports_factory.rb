# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :report do
    name 'Report 1'
    class_name 'BasicReportRow'
  end
end
