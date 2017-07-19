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

  factory :multipart_monday_1, class: 'Schedule' do
    start_time "6:00"
    end_time "10:00"
    day_of_week 1
  end

  factory :multipart_monday_2, class: 'Schedule' do
    start_time "16:00"
    end_time "20:00"
    day_of_week 1
  end

end
