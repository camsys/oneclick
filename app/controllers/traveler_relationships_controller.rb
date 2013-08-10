class TravelerRelationshipsController < ApplicationController

  authorize_resource class: BuddyRelationship

  def accept
    # TODO Not filtering to owned by current_user
    @buddy_relationship = BuddyRelationship.find(params[:id])
    @buddy_relationship.accept
    render partial: '/devise/registrations/travelers'
  end

  def decline
    # TODO Not filtering to owned by current_user
    @buddy_relationship = BuddyRelationship.find(params[:id])
    @buddy_relationship.reject
    render partial: '/devise/registrations/travelers'
  end

  def assist
    # TODO security
    assisting(BuddyRelationship.find(params[:id]).buddy)
    redirect_to '/'
  end

  def desist
    # TODO security
    stop_assisting
    redirect_to '/'
  end

end
