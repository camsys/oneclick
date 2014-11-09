require 'spec_helper'

describe TimeFilterHelper do
  subject { TimeFilterHelper }

  it { should respond_to(:time_filter_as_duration) }

  it 'should return a duration' do
    pending "This fails on travis when server time (e.g. EST) and UTC are in different days."
    TimeFilterHelper.time_filter_as_duration(TimeFilterHelper::TODAY_FILTER).should(eq(
      Date.today.beginning_of_day..Date.today.end_of_day))
  end

end
