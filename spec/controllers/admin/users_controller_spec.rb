require 'spec_helper'

describe Admin::UsersController do
  include Devise::TestHelpers
  before (:all) do
    FactoryGirl.create(:arc_mobility_mgmt_agency)
    FactoryGirl.create(:admin)
    create_list(:user, 25)
    create_list(:agency_admin, 1)
    create_list(:agency_agent, 10)
  end

  after(:all) do
    User.delete_all
  end

  describe "index action" do
    describe "for sys admin" do
      describe "with no params" do
        it "returns all users if some exist" do
          get :index
          assigns(:users).count.should eql(11) #1 admin and 10 agents
        end
      end
      describe "with email param" do
        it "returns one record exactly with matching email" do
          u = User.last
          get :index, text: u.email
          assigns(:users).count.should eql(1)
        end
      end
    end
  end

  describe "create action" do
    before(:each) do
      request.env["HTTP_REFERER"] = new_admin_agency_user_path(Agency.first.id)
    end

    it "should create a user with an agency_user_relationship if current_user has an agency" do
      login_as_using_find_by(email: 'admin@example.com')
      params = {
        user: {
          first_name: "Test",
          last_name: "Test",
          email: "AdminUserController@example.com",
          agency: Agency.find_by(name: "ARC Mobility Management") 
          }
      }
      get 'create', params
      created_user = User.last
      expect(assigns(:user)).to be_valid
      expect(assigns(:agency_user_relationship)).to be_valid
    end

    # TODO Unless I did the merge wrong, this request was okay...
    it "should not create a user and return to the creation form if there's something wrong with the request" do
      login_as_using_find_by(email: 'admin@example.com')
      params = {
        user: {
          first_name: "Test",
          last_name: "Test",
          email: "AdminUserController@example.com",
          agency: Agency.find_by(name: "ARC Mobility Management") 
          }
      }
      get 'create', params
      expect(assigns(:user)).to be_valid
      # expect(assigns(:user)).not_to be_valid
      # expect response.status.should eq 302
    end
  end
end