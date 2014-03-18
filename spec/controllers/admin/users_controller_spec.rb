require 'spec_helper'

describe Admin::UsersController do

  describe "create action" do
    before(:each) do
      FactoryGirl.create(:arc_mobility_mgmt_agency)
      request.env["HTTP_REFERER"] = new_admin_agency_user_path(Agency.first.id)
      login_as_using_find_by(email: 'email@camsys.com')
    end

      it "should use the current users agency if it exists" do
          params = {:user =>  {:approved_agencies => Agency.find_by(name: "ARC Mobility Management") } }
          get 'create', params
          expect(assigns(:agency).name).to eq("ARC Mobility Management")
      end

      it "should create a user with an agency_user_relationship if current_user has an agency" do
        params = {
          user: {
            first_name: "Test",
            last_name: "Test",
            email: "AdminUserController@example.com",
            password: "welcome1",
            password_confirmation: "welcome1",
            approved_agencies: Agency.find_by(name: "ARC Mobility Management") 
            }
        }
        get 'create', params
        expect(assigns(:user).valid?).to be(true)
      end

      it "should not create a user and return to the creation form if there's something wrong with the request" do
        params = {
          user: {
            first_name: "Test",
            last_name: "Test",
            email: "AdminUserController@example.com",
            password: "welcome1",
            password_confirmation: "welcome2",
            approved_agencies: Agency.find_by(name: "ARC Mobility Management") 
            }
        }
        get 'create', params
        expect(assigns(:user).valid?).to be(false)
        expect response.status.should eq 302
      end

  end


end