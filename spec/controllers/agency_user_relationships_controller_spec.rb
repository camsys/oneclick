require 'spec_helper'

describe AgencyUserRelationshipsController do
    describe "create action" do
        it "should add a relationship" do
            user = login_as(:admin)
            agency = FactoryGirl.build(:arc_mobility_mgmt_agency)
            User.find(user.id).approved_agencies.count.should eql(0)

            params_hash = {:agency_user_relationship => {:agency => agency.id}}
            post :create, params_hash
            User.find(user.id).approved_agencies.count.should eql(1)
        end
    end

    describe "traveler_revoke action" do
        it "should remove a relationship if it exists " do
            user = login_as(:admin)
            agency = FactoryGirl.build(:arc_mobility_mgmt_agency)
            user.agency = agency
            traveler = FactoryGirl.create(:user2)
            traveler.approved_agencies << user.agency
            User.find(user.id).approved_agencies.count.should eql(1)

            get :traveler_revoke, user.id, agency.id
            traveler.approved_agencies.count.should eql(1)
        end

        it "should do nothing if no relationship exists " do
            agency = FactoryGirl.build(:arc_mobility_mgmt_agency)
            traveler = FactoryGirl.create(:user2)
            User.find(user.id).approved_agencies.count.should eql(0)

            get :traveler_revoke, user.id, agency.id
            traveler.approved_agencies.count.should eql(1)
        end
    end


    describe "agency_revoke action" do
    end

end
