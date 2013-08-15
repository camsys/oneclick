class UserRelationshipsController < ApplicationController

  # A traveler creates a new delegate (buddy) request
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
    @traveler_relationship = UserRelationship.new
        
  end

  # A traveler hides a buddy request.
  def traveler_hide
    
    # get the user_relationship from the delegate_relationships for the logged in user (traveler)    
    @delegate_relationship = current_user.delegate_relationships.find(params[:id])
    if @delegate_relationship
      @delegate_relationship.relationship_status = RelationshipStatus.hidden
      if @delegate_relationship.save
        flash[:info] = "Database updated"
      else
        flash[:alert] = "Unable to update the database."
      end       
    else
      @delegate_relationship = UserRelationship.new
    end
    @traveler_relationship = UserRelationship.new
        
  end

  # A traveler is retracting an unconfirmed request.
  def traveler_retract

    # get the user_relationship from the delegate_relationships for the logged in user (traveler)    
    @delegate_relationship = current_user.delegate_relationships.find(params[:id])
    if @delegate_relationship
      @delegate_relationship.relationship_status = RelationshipStatus.hidden
      if @delegate_relationship.save
        flash[:info] = "Database updated"
      else
        flash[:alert] = "Unable to update the database."
      end       
    end      

  end

  # A traveler revokes a confirmed request
  def traveler_revoke
    
    # get the user_relationship from the delegate_relationships for the logged in user (traveler)    
    @delegate_relationship = current_user.delegate_relationships.find(params[:id])
    if @delegate_relationship
      @delegate_relationship.relationship_status = RelationshipStatus.revoked
      if @delegate_relationship.save
        UserMailer.buddy_revoke_email(@delegate_relationship.delegate.email, @delegate_relationship.traveler.email).deliver
        flash[:info] = "Buddy confirmation sent!"
      else
        flash[:alert] = "Unable to send confirmation."
      end       
    else
      flash[:alert] = "Unable to send confirmation."
      @delegate_relationship = UserRelationship.new
    end
    @traveler_relationship = UserRelationship.new
        
  end

  # A delegate (buddy) accepts an request
  def delegate_accept

    # get the user_relationship from the traveler_relationships for the logged in user (delegate)    
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
    @delegate_relationship = UserRelationship.new
            
  end

  # A delegate declines a request
  def delegate_decline
    
    # get the user_relationship from the traveler_relationships for the logged in user (delegate)    
    @traveler_relationship = current_user.traveler_relationships.find(params[:id])
    if @traveler_relationship
      @traveler_relationship.relationship_status = RelationshipStatus.declined
      if @traveler_relationship.save
        UserMailer.traveler_decline_email(@traveler_relationship.traveler.email, @traveler_relationship.delegate.email).deliver
        flash[:info] = "Buddy decline notification sent!"
      else
        flash[:alert] = "Unable to send notification."
      end       
    else
      flash[:alert] = "Unable to send confirmation."
      @traveler_relationship = UserRelationship.new
    end
    @delegate_relationship = UserRelationship.new
  end
  

  def delegate_revoke
    
    # get the user_relationship from the traveler_relationships for the logged in user (delegate)    
    @traveler_relationship = current_user.traveler_relationships.find(params[:id])
    if @traveler_relationship
      @traveler_relationship.relationship_status = RelationshipStatus.revoked
      if @traveler_relationship.save
        UserMailer.traveler_revoke_email(@traveler_relationship.traveler.email, @traveler_relationship.delegate.email).deliver
        flash[:info] = "Buddy confirmation sent!"
      else
        flash[:alert] = "Unable to send confirmation."
      end       
    else
      flash[:alert] = "Unable to send confirmation."
      @traveler_relationship = UserRelationship.new
    end
    @delegate_relationship = UserRelationship.new        
  end
    
end