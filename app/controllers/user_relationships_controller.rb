class UserRelationshipsController < ApplicationController

  def create
    
    email = params[:user_relationship][:email]
    # Lookup the delegate request by email
    delegate = User.find_by_email(email)
    # if we found it...
    if delegate
      # add the relationship to the DB with a pending status
      @delegate_relationship = UserRelationship.new
      @delegate_relationship.traveler = current_user
      @delegate_relationship.delegate = delegate
      @delegate_relationship.relationship_status = RelationshipStatus.requested
      # TODO: All emails should be sent from a worker thread not here!
      if @delegate_relationship.save
        UserMailer.buddy_request_email(@delegate_relationship.delegate.email, @delegate_relationship.traveler.email).deliver
        @delegate_relationship.relationship_status = RelationshipStatus.pending
        @delegate_relationship.save
        flash[:info] = "Buddy request sent!"
      else
        flash[:alert] = "Unable to send request."
      end       
    else
      @delegate_relationship = UserRelationship.new
      flash[:warn] = "No registered users with email address #{email}."       
    end
        
  end

  def accept
    
    # Lookup the delegate request by email
    @traveler_relationship = current_user.traveler_relationships.find(params[:id])
    if @traveler_relationship
      @traveler_relationship.relationship_status = RelationshipStatus.confirmed
      if @traveler_relationship.save
        UserMailer.traveler_confirmation_email(@traveler_relationship.traveler.email, @traveler_relationship.delegate.email).deliver
        flash[:info] = "Buddy confirmation sent!"
      else
        flash[:alert] = "Unable to send confirmation."
      end       
    else
      flash[:alert] = "Unable to send confirmation."
      @traveler_relationship = UserRelationship.new
    end
        
  end

  def decline
    
    # Lookup the delegate request by email
    @traveler_relationship = current_user.traveler_relationships.find(params[:id])
    if @traveler_relationship
      @traveler_relationship.relationship_status = RelationshipStatus.declined
      if @traveler_relationship.save
        UserMailer.traveler_confirmation_email(@traveler_relationship.traveler.email, @traveler_relationship.delegate.email).deliver
        flash[:info] = "Buddy confirmation sent!"
      else
        flash[:alert] = "Unable to send confirmation."
      end       
    else
      flash[:alert] = "Unable to send confirmation."
      @traveler_relationship = UserRelationship.new
    end
        
  end
  
  def revoke
    
    # Lookup the delegate request by email
    @traveler_relationship = current_user.traveler_relationships.find(params[:id])
    if @traveler_relationship
      @traveler_relationship.relationship_status = RelationshipStatus.revoked
      if @traveler_relationship.save
        UserMailer.traveler_confirmation_email(@traveler_relationship.traveler.email, @traveler_relationship.delegate.email).deliver
        flash[:info] = "Buddy confirmation sent!"
      else
        flash[:alert] = "Unable to send confirmation."
      end       
    else
      flash[:alert] = "Unable to send confirmation."
      @traveler_relationship = UserRelationship.new
    end
        
  end
  
end