require 'spec_helper'

describe UserProfile do

  it "has eligibility information" do
    user_profile = FactoryGirl.create(:user_profile)
    user_profile.traveler_accommodations.should_not be_empty
    user_profile.traveler_accommodations.first.name.should eq 'Wheelchair Accessible'
  end

  it "has veteran characteristic" do
    user_profile = FactoryGirl.create(:user_profile)
    user_profile.traveler_characteristics.should_not be_empty
    user_profile.traveler_characteristics.first.code.should eq 'veteran'
  end

  it "has characteristic maps" do
    user_profile = FactoryGirl.create(:user_profile)
    user_profile.user_traveler_characteristics_maps.should_not be_nil
  end

  it "has eligible services" do
    #load "#{Rails.root}/db/seeds.rb"
    user_profile = FactoryGirl.create(:user_profile)
    user_profile.traveler_characteristics.should_not be_empty
    eh = EligibilityHelpers.new
    user_profile.traveler_characteristics.first.code.should eq 'veteran'
    services = eh.get_eligible_services_for_traveler(user_profile)
    services.should eq []

  end
end