require 'spec_helper'

describe Admin::HomeController do

  describe "GET 'index'" do
    before(:each) do
      FactoryGirl.create(:populated_service)
    end
    it "redirects if not logged in" do
      get :index
      response.status.should eq 302
    end
    it "does not redirect if logged in as an admin" do
      login_as(:admin)
      get :index
      response.status.should eq 200
    end
    it "redirects if logged in as non-admin user" do
      login_as(:user)
      get :index
      response.status.should eq 302
    end
  end

end
