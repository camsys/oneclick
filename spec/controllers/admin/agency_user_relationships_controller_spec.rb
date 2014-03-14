require 'spec_helper'

describe Admin::AgencyUserRelationshipsController do
   # describe "create action" do
    #     it "should add a relationship" do
    #         login_as_using_find_by(email: "email@camsys.com")
    #         user = User.find(1)
    #         agency = FactoryGirl.create(:arc_mobility_mgmt_agency)
    #         User.find(user.id).approved_agencies.count.should eql(0)

    #         params_hash = {:agency_id => agency.id, user_id: user.id}
    #         post :create, params_hash
    #         User.find(user.id).approved_agencies.count.should eql(1)
    #     end
    # end

    # describe "traveler_revoke action" do
    #     it "should remove a relationship if it exists " do
    #         login_as_using_find_by(email: "email@camsys.com")
    #         user = User.find(1)
    #         agency = FactoryGirl.create(:arc_mobility_mgmt_agency)
    #         user.agency = agency
    #         traveler = FactoryGirl.create(:user2)
    #         traveler.agency_user_relationships.create( agency_id: agency.id, creator: user.id )
    #         traveler.approved_agencies << user.agency
    #         User.find(1).approved_agencies.count.should eql(1)

    #         get :traveler_revoke, user.id, agency.id
    #         traveler.approved_agencies.count.should eql(1)
    #     end

        # it "should do nothing if no relationship exists " do
        #     agency = FactoryGirl.build(:arc_mobility_mgmt_agency)
        #     traveler = FactoryGirl.create(:user2)
        #     User.find(traveler.id).approved_agencies.count.should eql(0)

        #     get :traveler_revoke, user_id: traveler.id, agency.id
        #     traveler.approved_agencies.count.should eql(1)
        # end
    # end


    # describe "agency_revoke action" do
    # end

    before (:all) do
        FactoryGirl.create(:arc_mobility_mgmt_agency)
    end

    before (:each) do
        login_as_using_find_by(email: 'email@camsys.com')
    end

    describe "index action" do
        describe "with no params" do
            it "returns no users if there are none" do
                get :index, agency_id: Agency.first.id
                assigns(:users).count.should eql(1) #Because the admin user exists
            end
            it "returns all users if some exist" do
                create_list(:user, 25)
                get :index, agency_id: Agency.first.id
                assigns(:users).count.should eql(26) #25 created users plus the admin
            end
        end
        describe "with email param" do
            it "returns one record exactly with matching email" do
                create_list(:user, 25)
                u = User.last
                get :index, text: u.email, agency_id: Agency.first.id
                assigns(:users).count.should eql(1)
            end
        end
    end
end
