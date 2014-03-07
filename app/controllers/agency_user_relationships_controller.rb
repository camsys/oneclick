class AgencyUserRelationshipsController < ApplicationController
    def create(traveler, agency)
        agency = Agency.find(agency || params[:agency_user_relationship][:agency])

        if agency
            @agency_user_relationship = AgencyUserRelationship.new
            @agency_user_relationship.user = traveler || get_traveler
            @agency_user_relationship.agency = agency
            @agency_user_relationship.creator = current_user
        end

        if @agency_user_relationship.save
            respond_to do |format|
                format.js {render "user_relationships/update_buddy_table"}
            end
        end
    end
end
