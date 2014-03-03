require 'spec_helper'

describe Admin::UsersController do

	before (:each) do
		login_as(:admin)
	end

	describe "index action" do
		describe "with no params" do
			it "returns no users if there are none" do
				get :index
				assigns(:users).count.should eql(1)	#Because the admin user exists
			end
			it "returns all users if some exist" do
				puts "created users"
				create_list(:user, 25)
				get :index
				assigns(:users).count.should eql(26) #25 created users plus the admin
			end
		end
		describe "with email param" do
			it "returns one record exactly with matching email" do
				create_list(:user, 25)
				get :index, text: 'email44@factory.com'
				assigns(:users).count.should eql(1)
			end
		end
	end
end