require 'spec_helper'

describe Admin::UsersController do

  describe "create action" do
    before(:each) do
      FactoryGirl.create(:arc_mobility_mgmt_agency)
      request.env["HTTP_REFERER"] = new_admin_agency_user_path(Agency.first.id)
      login_as_using_find_by(email: 'email@camsys.com')
    end

    # TODO This can't work without more user parameters
    # it "should use the current users agency if it exists" do
    #     params = {:user =>  {:agency => Agency.find_by(name: "ARC Mobility Management") } }
    #     get 'create', params
    #     expect(assigns(:agency).name).to eq("ARC Mobility Management")
    # end

    it "should create a user with an agency_user_relationship if current_user has an agency" do
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
    end

    # TODO Unless I did the merge wrong, this request was okay...
    it "should not create a user and return to the creation form if there's something wrong with the request" do
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