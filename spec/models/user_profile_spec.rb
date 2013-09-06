require 'spec_helper'

describe UserProfile do
  it "has eligibility information" do
    user_profile = FactoryGirl.create(:user_profile)
    user_profile.traveler_accommodations.should_not be_empty
    user_profile.traveler_accommodations.first.name.should eq 'Wheelchair Accessible'
  end
end
