require 'spec_helper'

describe Admin::UsersController do

	before (:each) do
		login_as_using_find_by(email: 'email@camsys.com')
	end

	describe "index action" do
		describe "with no params" do
			it "returns no users if there are none" do
				get :index
				assigns(:users).count.should eql(1)	#Because the admin user exists
			end
			it "returns all users if some exist" do
				create_list(:user, 25)
				get :index
				assigns(:users).count.should eql(26) #25 created users plus the admin
			end
		end
		describe "with email param" do
			it "returns one record exactly with matching email" do
				create_list(:user, 25)
				u = User.last
				get :index, text: u.email
				assigns(:users).count.should eql(1)
			end
		end
	end
end