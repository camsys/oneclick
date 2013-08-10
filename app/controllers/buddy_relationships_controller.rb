class BuddyRelationshipsController < ApplicationController

  authorize_resource

  def create
    Rails.logger.info "create"
    email_address = params[:buddy_relationship][:email_address]
    @buddy_relationship = current_user.add_buddy email_address
    Rails.logger.info @buddy_relationship.ai
    Rails.logger.info @buddy_relationship.valid?
    flash[:info] = "Buddy request sent!" if @buddy_relationship.valid?
    render partial: '/devise/registrations/buddies'
  end

end
