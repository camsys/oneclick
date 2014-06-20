require 'spec_helper'

describe TripPart do
  Timecop.freeze
  t = Time.now + 1.days
  let(:trip) {FactoryGirl.create(:trip, scheduled_date: t, scheduled_time: t)}
  let(:trip_part1) {FactoryGirl.create(:trip_part, scheduled_date: t, scheduled_time: t, trip: trip, sequence: 0)}
  let(:trip_part2) {FactoryGirl.create(:trip_part, scheduled_date: t+2.hours, scheduled_time: t+2.hours, trip: trip, sequence: 1)}

  subject{trip_part1}

  it { should be_valid }

  describe "2 trip parts" do
    describe "it can adjust its time successfully" do
      before(:each) do
        trip_part1.trip.trip_parts.destroy_all
        trip_part1.trip.trip_parts << trip_part1
        trip_part1.trip.trip_parts << trip_part2
        trip_part1.scheduled_date.should eq t.to_date
        trip_part1.scheduled_time.should eq t
      end

      it 'with a string' do
        trip_part1.trip.scheduled_time.to_datetime.should eq t.to_datetime
        trip_part1.reschedule("-30")
        trip_part1.reload
        trip_part1.scheduled_time.to_datetime.should eq (t - 30.minutes).to_datetime
        trip.scheduled_time.to_datetime.should eq (t - 30.minutes).to_datetime
      end

      it 'with a int' do
        trip_part1.reschedule(-30)
        trip_part1.reload
        trip_part1.scheduled_time.to_datetime.should eq (t - 30.minutes).to_datetime
      end

      it 'forward with a string' do
        trip_part1.reschedule("+30")
        trip_part1.reload
        trip_part1.scheduled_time.to_datetime.should eq (t + 30.minutes).to_datetime
      end

      it 'forward with a int' do
        trip_part1.reschedule(+30)
        trip_part1.reload
        trip_part1.scheduled_time.to_datetime.should eq (t + 30.minutes).to_datetime
      end
    end

    describe "it does not adjust its time past the other trip_part1's" do
      before(:each) do
        trip_part1.trip.trip_parts.destroy_all
        trip_part1.trip.trip_parts << trip_part1
        trip_part1.trip.trip_parts << trip_part2
        trip_part1.scheduled_date.to_datetime.should eq t.to_date.to_datetime
        trip_part1.scheduled_time.to_datetime.should eq t.to_datetime
        trip_part1.trip.trip_parts.count.should eq 2
        trip_part1.trip.trip_parts.first.should eq trip_part1
      end

      it 'forward' do
        expect{trip_part1.reschedule(+120)}.to raise_error
        expect{trip_part1.reschedule(+119)}.not_to raise_error
        expect{trip_part2.reschedule(+120)}.not_to raise_error
      end

      it 'backward' do
        expect{trip_part2.reschedule(-120)}.to raise_error
        expect{trip_part2.reschedule(-119)}.not_to raise_error
        expect{trip_part1.reschedule(-120)}.not_to raise_error
      end

    end

  end


  describe "1 trip part" do
    describe "it can adjust its time successfully" do
      before(:each) do
        trip_part1.trip.trip_parts.destroy_all
        trip_part1.trip.trip_parts << trip_part1
        trip_part1.scheduled_date.to_datetime.should eq t.to_date.to_datetime
        trip_part1.scheduled_time.to_datetime.should eq t.to_datetime
      end

      it 'with a string' do
        trip_part1.trip.scheduled_time.to_datetime.should eq t.to_datetime
        trip_part1.reschedule("-30")
        trip_part1.reload
        trip_part1.scheduled_time.to_datetime.should eq (t - 30.minutes).to_datetime
        trip.scheduled_time.to_datetime.should eq (t - 30.minutes).to_datetime
      end

      it 'with a int' do
        trip_part1.reschedule(-30)
        trip_part1.reload
        trip_part1.scheduled_time.to_datetime.should eq (t - 30.minutes).to_datetime
      end

      it 'forward with a string' do
        trip_part1.reschedule("+30")
        trip_part1.reload
        trip_part1.scheduled_time.to_datetime.should eq (t + 30.minutes).to_datetime
      end

      it 'forward with a int' do
        trip_part1.reschedule(+30)
        trip_part1.reload
        trip_part1.scheduled_time.to_datetime.should eq (t + 30.minutes).to_datetime
      end
    end

  end

end
