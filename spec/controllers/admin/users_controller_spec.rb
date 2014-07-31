require 'spec_helper'

describe Admin::UsersController do
  include Devise::TestHelpers
  before (:all) do
    User.delete_all
    FactoryGirl.create(:admin)
    @agency = FactoryGirl.create(:arc_mobility_mgmt_agency)
    create_list(:user, 25)
    @agency_admin = FactoryGirl.create(:agency_admin)
    create_list(:agency_agent, 10)
  end

  after(:all) do
    User.delete_all
  end

  describe "index action" do
    describe "for sys admin" do
      before(:each) do
        login_as_using_find_by(email: 'admin@example.com')
      end
      describe "with no params" do
        it "returns all users except visitors if some exist" do
          FactoryGirl.create :visitor
          get :index
          assigns(:users).count.should eql(38) #1 sys admin, 1 agency admin, 10 agents and 25 users, +1 unknown
        end
      end
    end
  end

  describe "create action" do
    before(:each) do
      request.env["HTTP_REFERER"] = new_admin_user_path(Agency.first.id)
    end

    it "should create a user with an agency_user_relationship if current_user has an agency" do
      pending "https://www.pivotaltracker.com/story/show/70102276"
      login_as_using_find_by(email: @agency_admin.email)
      params = {
        user: {
          first_name: "Valid",
          last_name: "Test",
          email: "AdminUserController@example.com",
          agency: Agency.find_by(name: "ARC Mobility Management"),
          password: "abcdefgh",
          password_confirmation: "abcdefgh"
          }
      }
      get 'create', params
      created_user = User.last
      expect(assigns(:user)).to be_valid
      expect(assigns(:agency_user_relationship)).to be_valid
    end

    it "should not create a user and return to the creation form if there's something wrong with the request" do
      login_as_using_find_by(email: 'admin@example.com')
      params = {
        user: {
          first_name: "Invalid",
          last_name: "Test",
          email: "AdminUserController@example.com",
          agency: Agency.find_by(name: "ARC Mobility Management") 
          #missing password information
          }
      }
      get 'create', params
      expect(assigns(:user)).not_to be_valid
      expect(assigns(:user).errors).not_to be_empty
      expect response.status.should eq 200
    end
  end
end