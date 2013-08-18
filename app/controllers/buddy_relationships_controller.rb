class BuddyRelationshipsController < ApplicationController

  authorize_resource

  def create
    email_address = params[:buddy_relationship][:email_address]
    @buddy_relationship = current_user.add_buddy email_address
    if @buddy_relationship.valid?
      flash[:info] = t(:buddy_request_sent) 
      @buddy_relationship = BuddyRelationship.new
    end
    render partial: '/devise/registrations/buddies'
    flash.discard
  end

  def revoke
    current_user.remove_buddy BuddyRelationship.find(params[:id])
    flash[:info] = t(:buddy_removed)
    @buddy_relationship = BuddyRelationship.new
    render partial: '/devise/registrations/buddies'
    flash.discard
  end

end
