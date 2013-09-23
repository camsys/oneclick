class UserRelationshipsController < ApplicationController
  
  before_filter :set_view_variables
  
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
        flash[:notice] = "Buddy request sent!"
      else
        flash[:alert] = "Unable to send request."
      end       
    else
      @delegate_relationship = UserRelationship.new
      flash[:alert] = "No registered users with email address #{email}."       
    end

    respond_to do |format|
      format.js {render "update_buddy_table"}
    end
       
  end

  # A traveler hides a buddy request.
  def traveler_hide
    
    update_delegate_relationship(current_user, params[:id], RelationshipStatus.hidden)
    respond_to do |format|
      format.js {render "update_buddy_table"}
    end
        
  end

  # A traveler is retracting an unconfirmed request.
  def traveler_retract

    update_delegate_relationship(current_user, params[:id], RelationshipStatus.hidden)
    respond_to do |format|
      format.js {render "update_buddy_table"}
    end

  end

  # A traveler revokes a confirmed request
  def traveler_revoke

    update_delegate_relationship(current_user, params[:id], RelationshipStatus.revoked)
    respond_to do |format|
      format.js {render "update_buddy_table"}
    end
           
  end

  # A delegate (buddy) accepts an request
  def delegate_accept
    
    update_traveler_relationship(current_user, params[:id], RelationshipStatus.confirmed, 1)
    respond_to do |format|
      format.js {render "update_traveler_table"}
    end
            
  end

  # A delegate declines a request
  def delegate_decline

    update_traveler_relationship(current_user, params[:id], RelationshipStatus.denied, 2)
    respond_to do |format|
      format.js {render "update_traveler_table"}
    end
    
  end
  
  # A delegate revokes the ability to perform funcitons on behalf of a traveler
  def delegate_revoke

    update_traveler_relationship(current_user, params[:id], RelationshipStatus.revoked, 3)
    respond_to do |format|
      format.js {render "update_traveler_table"}
    end
    
  end
    
private
  
  def set_view_variables
    # these calls are ajaxed so we need to remove any existing flash messages
    flash[:notice] = nil
    flash[:alert] = nil
    @user_relationship = UserRelationship.new
  end
  
  # Updates the status of a delegate relationship by the current user (traveler)
  def update_delegate_relationship(user, delegate_relationship_id, new_status)
    # get the user_relationship from the delegate_relationships for the logged in user (traveler)    
    @delegate_relationship = user.delegate_relationships.find(delegate_relationship_id)
    if @delegate_relationship
      @delegate_relationship.relationship_status = new_status
      if @delegate_relationship.save
        flash[:notice] = "Database updated"
      else
        flash[:alert] = "Unable to update the database."
      end       
    end
  end   

  # Updates the status of a traveler relationship by the current user (delegate)
  def update_traveler_relationship(user, traveler_relationship_id, new_status, email_type)
    # get the user_relationship from the traveler_relationships for the logged in user (delegate)    
    @traveler_relationship = user.traveler_relationships.find(traveler_relationship_id)
    if @traveler_relationship
      @traveler_relationship.relationship_status = new_status
      if @traveler_relationship.save
        # TODO: All emails should be sent from a worker thread not here!
        send_update_email(@traveler_relationship.delegate, @traveler_relationship.traveler, email_type)
        flash[:notice] = "Email sent!"
      else
        flash[:alert] = "Unable to send confirmation."
      end       
    end
  end   
    
  # Sends an update email from the delegate to the traveler
  def send_update_email(delegate, traveler, email_type)
    if email_type == 1
      UserMailer.traveler_confirmation_email(traveler.email, delegate.email).deliver
    elsif email_type == 2
      UserMailer.traveler_decline_email(traveler.email, delegate.email).deliver
    elsif email_type == 3
      UserMailer.traveler_revoke_email(traveler.email, delegate.email).deliver
    end
  end
end