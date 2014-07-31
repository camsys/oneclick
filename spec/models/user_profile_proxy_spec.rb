require 'spec_helper'

describe UserProfileProxy do

  subject(:upp) { UserProfileProxy.new }

  describe 'converts dates' do
    it 'when it is just a year' do
      upp.convert_value(Characteristic.new(datatype: 'date'), {date: '1975'}).should eq Chronic.parse('1-1-1975')
    end
    it 'when it is a date string' do
      upp.convert_value(Characteristic.new(datatype: 'date'), {date: '10-1-1975'}).should eq Chronic.parse('1-10-1975')
    end
    it 'when it is individual values' do
      upp.convert_value(Characteristic.new(datatype: 'date'), {day: '1', month: '10', year: '1975'}).should eq Chronic.parse('1-10-1975')
    end
  end

end
