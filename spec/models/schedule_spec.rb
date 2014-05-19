require 'spec_helper'

describe Schedule do

  let(:schedule) {FactoryGirl.create(:schedule)}

  subject{schedule}

  it { should be_valid }

  it 'can set schedule via start_time and end_time methods' do
    # TODO This needs to be fixed somehow.
    pending "Fails on the date DST starts/ends"
    schedule.start_time = '10:10 AM'
    schedule.end_time = '5:00 PM'
    schedule.start_seconds.should eq 36600
    schedule.end_seconds.should eq 61200
  end

  it 'should set validation flags on input' do
    schedule.start_time = ''
    schedule.end_time = ''

    schedule.start_time_present.should be_false
    schedule.end_time_present.should be_false

    schedule.start_time = 'foo'
    schedule.end_time = 'foo'

    schedule.start_time_valid.should be_false
    schedule.end_time_valid.should be_false
    
  end

  it 'should accept empty start and end times' do
    FactoryGirl.build(:schedule, start_time: '', end_time: '').should be_valid
  end

  it 'should allow eight_to_five_wednesday' do
    FactoryGirl.build(:eight_to_five_wednesday).should be_valid
  end
  
  it 'should require valid start and end time' do
    FactoryGirl.build(:schedule, start_time: '', end_time: '1pm').should have(1).errors_on(:"1start_time")

    FactoryGirl.build(:schedule, start_time: '1pm', end_time: '').should have(1).errors_on(:"1end_time")

    FactoryGirl.build(:schedule, start_time: 'foo', end_time: '1pm').should have(1).errors_on(:"1start_time")

    FactoryGirl.build(:schedule, start_time: '1pm', end_time: 'foo').should have(1).errors_on(:"1end_time")

    FactoryGirl.build(:schedule, start_time: '2pm', end_time: '1pm').should have(1).errors_on(:"1start_time")

    
  end
  
end
