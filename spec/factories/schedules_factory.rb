FactoryGirl.define do
  factory :schedule do
    service
    day_of_week 1
  end

  factory :eight_to_five_wednesday, class: 'Schedule' do
    start_time "8:00"
    end_time "17:00"
    day_of_week 3
  end

end
