require 'spec_helper'

describe RatingsController do
  before(:all) do
    @admin_user = FactoryGirl.create(:admin)    
  end
  before (:each) do
    login_as_using_find_by(email: @admin_user.email)
  end

  describe "get INDEX'" do
    it "should be successful when logged in" do
      get "index"
      expect(response).to be_success
    end
  end

  describe "post 'approve'" do
    it "should approve passed ratings" do
      r = FactoryGirl.create :rating
      patch 'approve', {approve: {r.id.to_s => Rating::APPROVED}.to_query}
      r.reload
      expect(r.approved?).to be_true
    end
    it "should reject deleted ratings" do
      r = FactoryGirl.create :rating
      patch 'approve', {approve: {r.id.to_s => Rating::REJECTED}.to_query}
      r.reload
      expect(r.rejected?).to be_true
    end
  end
end