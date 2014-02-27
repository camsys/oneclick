require 'spec_helper'

describe Schedule do

  let(:schedule) {FactoryGirl.create(:schedule)}

  subject{schedule}

  it { should be_valid }

  it 'can set schedule via start_time and end_time methods' do
    schedule.start_time = '10:10 AM'
    schedule.end_time = '5:00 PM'
    schedule.start_seconds.should eq 36600
    schedule.end_seconds.should eq 61200
  end
end
