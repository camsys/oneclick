class Admin::AgencyUserRelationshipsController < Admin::BaseController
  # TODO Not working yet, needs rework
  # load_and_authorize_resource
  before_filter :set_view_variables #clear out the flash messages, set @user
  skip_authorization_check :only => [:create, :traveler_revoke, :traveler_hide, :agency_revoke]# TODO This should get cancan'd at some point, but currently any user can do this at any time
    

  def index ##TODO Remove?
    if params[:agency_id]
      @agency = Agency.find(params[:agency_id])
      authorize! :manage_travelers, @agency
    else
      @agency = Agency.new(name: 'All agencies') # to keep later things from blowing up
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

    if params[:agency_user_relationship][:agency_id] 
      #create one relationship for each agency
      params[:agency_user_relationship][:agency_id].split(",").each do |a_id|
        unless a_id.empty? # Simple form keeps adding a blank, so need to catch that
          agency = Agency.find(a_id)

          if agency
            @agency_user_relationship = AgencyUserRelationship.new  #defaults to Status = 3, i.e. Active
            @agency_user_relationship.user = @user
            @agency_user_relationship.agency = agency
            @agency_user_relationship.creator = current_user.id
          end

          if @agency_user_relationship.save
            flash[:notice] = TranslationEngine.translate_text(:agency_added)
          end
        end
      end
    else
      flash[:alert] = TranslationEngine.translate_text(:no_agency_selected)
    end
    #AJAX update the tables with newest information regardless of success
    respond_to do |format|
      format.js {render "shared/update_user_relationship_tables", locals: @locals }
    end
  end

  # Impersonate a user to edit_user_path their traveler profile.
  def edit
    authorize! :assist, @user
    agency_staff_assist_user(params[:id], params[:agency_id])
    redirect_to edit_user_path params[:id]   #edit_user_path is not user#edit, because of Devise.  Actually points to registration_controller#edit
  end

private
  def set_view_variables
    # these calls are ajaxed so we need to remove any existing flash messages
    flash[:notice] = nil
    flash[:alert] = nil
    @agency_user_relationship = AgencyUserRelationship.new
    @user = User.find(params[:user_id])
    target = params[:agency_user_relationship][:messagesFieldName]
    @locals = {user: @user, target_name: target}
  end

  # Updates the status of a delegate relationship by the current user (traveler)
  def update_agency_relationship(user, agency_relationship_ip, new_status)
    @agency_relationship = user.agency_user_relationships.find(agency_relationship_ip)
    if @agency_relationship
      @agency_relationship.relationship_status = new_status
      if @agency_relationship.save
        flash[:notice] = TranslationEngine.translate_text(:request_processed)
      else
        flash[:alert] = TranslationEngine.translate_text(:something_went_wrong)
      end       
    end
  end   

end

