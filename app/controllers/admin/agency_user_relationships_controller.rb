class Admin::AgencyUserRelationshipsController < ApplicationController
  # TODO Not working yet, needs rework
  # load_and_authorize_resource

  def index
    if params[:agency_id]
      @agency = Agency.find(params[:agency_id])
      authorize! :manage_travelers, @agency
    else
      @agency = Agency.new(name: 'multiple') # to keep later things from blowing up
      authorize! :manage_travelers, Agency
    end

    if params[:text]
      @users = User.where("upper(first_name) LIKE ? OR upper(last_name) LIKE ? OR upper(email) LIKE ?", 
        "%#{params[:text].upcase}%", "%#{params[:text].upcase}%", "%#{params[:text].upcase}%")
    else
      @users = User.all
    end
    @users = @users.registered unless params[:visitors]
    @users = @users.delete_if{ |x| x.roles.count > 0} if params[:traveler]
    respond_to do |format|
      format.html
      format.json { render json: @users }
    end
  end
  

  def create
    agency = Agency.find(params[:agency_user_relationship][:agency])

    if agency
            @agency_user_relationship = AgencyUserRelationship.new  #defaults to Status = 3, i.e. Active
            @agency_user_relationship.user = params[:traveler_id]||get_traveler
            @agency_user_relationship.agency = agency
            @agency_user_relationship.creator = current_user.id
          end

          if @agency_user_relationship.save
            unless (get_traveler == current_user)   #don't send email if they picked themself up
              UserMailer.agency_helping_email(@agency_user_relationship.user.email, @agency_user_relationship.user.email, agency).deliver
            end
            flash[:notice] = t(:agency_added)

            respond_to do |format|
              format.js {render "user_relationships/update_buddy_table"}
            end
          end
        end

  # Impersonate a user to edit their traveler profile.
  def edit
    agency_staff_impersonate(params[:id], params[:agency_id])
    redirect_to edit_user_path params[:id]   #edit_user_path is not user#edit, because of Devise.  Actually points to registration_controller#edit
  end


  def aid_user
    agency_staff_impersonate(params[:traveler_id], params[:agency_id])
    redirect_to new_user_trip_path(params[:traveler_id])
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

  def agency_staff_impersonate(user_id, agency_id)
    @agency_user_relationship = AgencyUserRelationship.find_or_create_by(user_id: user_id, agency_id: agency_id) do |aur|
      aur.creator = current_user.id
    end
    set_traveler_id user_id
  end

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

