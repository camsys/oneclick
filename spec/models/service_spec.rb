require 'spec_helper'

describe Service do

  it "has a schedule" do
    service = FactoryGirl.create(:service)
    service.name.should eq 'Test Service'
  end

  it "has eligibility information" do
    service = FactoryGirl.create(:service)
    service.traveler_accommodations.should_not be_empty
    service.traveler_accommodations.first.name.should eq 'Wheelchair Accessible'
  end

end
