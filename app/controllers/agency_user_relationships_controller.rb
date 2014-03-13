class AgencyUserRelationshipsController < ApplicationController
    

    # GET /users
    # GET /users.json
    def index
      #Get the broadest list of user
      if params[:text]# and params[:text]  != [""]
        @users = User.where("upper(first_name) LIKE ? OR upper(last_name) LIKE ? OR upper(email) LIKE ?", 
          "%#{params[:text].upcase}%", "%#{params[:text].upcase}%", "%#{params[:text].upcase}%")
      else
        @users = User.all
      end
      ##winnow down
      @users = @users.registered unless params[:visitors]
      @users = @users.delete_if{ |x| x.roles.count > 0} if params[:traveler]
      respond_to do |format|
        format.html { render :index}
        format.json { render json: @users }
      end
    end
    


    def create
        agency = Agency.find(params[:agency_user_relationship][:agency])

        if agency
            @agency_user_relationship = AgencyUserRelationship.new  #defaults to Status = 3, i.e. Active
            @agency_user_relationship.user = get_traveler
            @agency_user_relationship.agency = agency
            @agency_user_relationship.creator = current_user.id
        end

        if @agency_user_relationship.save
            if (get_traveler == current_user)   #don't send email if they picked themself up
                UserMail.agency_helping_email(@agency_user_relationship.user.email, @agency_user_relationship.user.email, agency).deliver
            end
            flash[:notice] = t(:agency_added)

            respond_to do |format|
                format.js {render "user_relationships/update_buddy_table"}
            end
        end
    end

  # A traveler revokes a  request
  def traveler_revoke
  update_agency_relationship(current_user, params[:id], RelationshipStatus.revoked)
    respond_to do |format|
      format.js {render "user_relationships/update_buddy_table"}
    end
  end

  # A traveler hides a buddy request.
  def traveler_hide
    update_agency_relationship(User.find(params[:user_id]), params[:id], RelationshipStatus.hidden)
    respond_to do |format|
      format.js {render "user_relationships/update_buddy_table"}
    end
        
  end

  ##TODO Talk with Denis about what he wants this to be
  def agency_revoke
    update_agency_relationship(current_user, params[:id], RelationshipStatus.revoked)
  end

private
  
  # Updates the status of a delegate relationship by the current user (traveler)
  def update_agency_relationship(user, agency_relationship_ip, new_status)
    @agency_relationship = user.agency_user_relationships.find(agency_relationship_ip)
    if @agency_relationship
      @agency_relationship.relationship_status = new_status
      if @agency_relationship.save
        flash[:notice] = t(:request_processed)
      else
        flash[:alert] = t(:something_went_wrong)
      end       
    end
  end   

end
