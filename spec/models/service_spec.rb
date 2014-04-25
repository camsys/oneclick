require 'spec_helper'

describe Service do

  before (:each) do
    @service = FactoryGirl.create(:populated_service)
  end
  
  it "has a schedule" do
    @service.name.should eq 'Test Service'
  end

  it "has eligibility information" do
    @service.accommodations.should_not be_empty
    @service.accommodations.first.name.should eq 'Wheelchair Accessible'
  end

  it "has an internal contact" do
    @service.users.should_not be_empty
    @service.internal_contact.should_not be nil
    @service.internal_contact.name.should eq 'Service Contact'
  end

  it "can update internal contact" do
    @service.internal_contact.name.should eq 'Service Contact'

    user = FactoryGirl.create(:user)
    @service.internal_contact = user
    @service.reload
    @service.internal_contact.should eq user
  end
  
end
