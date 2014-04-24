require 'spec_helper'

describe Service do

  it "has a schedule" do
    service = FactoryGirl.create(:populated_service)
    service.name.should eq 'Test Service'
  end

  it "has eligibility information" do
    service = FactoryGirl.create(:populated_service)
    service.accommodations.should_not be_empty
    service.accommodations.first.name.should eq 'Wheelchair Accessible'
  end

  it "has an internal contact" do
    service = FactoryGirl.create(:populated_service)
    service.users.should_not be_empty
    service.internal_contact.should_not be nil
    service.internal_contact.name.should eq 'Service Contact'
  end

end
