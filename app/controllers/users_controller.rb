class UsersController < ApplicationController
  load_and_authorize_resource
  before_filter :authenticate_user!

  def index
    authorize! :index, User, :message => t(:not_authorized_as_an_administrator)
    @users = User.all
  end

  def show
    authorize! :show, @user
    @user_characteristics_proxy = UserCharacteristicsProxy.new(@user)
    @user_programs_proxy = UserProgramsProxy.new(@user)
    @user_accommodations_proxy = UserAccommodationsProxy.new(@user)
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
    @user_characteristics_proxy = UserCharacteristicsProxy.new(User.find(@user)) #we inflate a new proxy every time, but it's transient, just holds a bunch of characteristics
    
    # Getting around devise- since password can't be blank, don't try to update it if they didn't pass it
    update_method = params[:password].blank? ? user_params_without_password : user_params_with_password
    if @user.update_attributes!(update_method)
      @user_characteristics_proxy.update_maps(params[:user_characteristics_proxy])
      set_approved_agencies(params[:user][:approved_agency_ids])
      set_booking_services(@user, params[:user_service])
      @user.set_buddies(params[:user][:pending_and_confirmed_delegate_ids])
      redirect_to user_path(@user, locale: @user.preferred_locale), :notice => "User updated."
    else
      redirect_to edit_user_path(@user), :alert => "Unable to update user."
    end
  end
    
  def destroy
    authorize! :destroy, @user, :message => t(:not_authorized_as_an_administrator)
    user = User.find(params[:id])
    unless user == current_user
      user.destroy
      redirect_to user_path, :notice => "User deleted."
    else
      redirect_to user_path, :notice => "Can't delete yourself."
    end
  end

  def edit
    # set_traveler_id params[:id] || current_user
    authorize! :edit, @user
    @agency_user_relationship = AgencyUserRelationship.new
    @user_relationship = UserRelationship.new
    @user_characteristics_proxy = UserCharacteristicsProxy.new(@user)
    @user_programs_proxy = UserProgramsProxy.new(@user)
    @user_accommodations_proxy = UserAccommodationsProxy.new(@user)
  end


private

  def user_params_without_password
    params.require(:user).permit(:first_name, :last_name, :email, :preferred_locale)
  end

  def user_params_with_password
    params.require(:user).permit(:first_name, :last_name, :email, :preferred_locale, :password, :password_confirmation)
  end

  def set_approved_agencies(ids)
    new_agency_ids = ids.reject!(&:empty?) # Simple form keeps adding a blank, so strip that out
    old_agency_ids = @user.approved_agencies.pluck(:id).map(&:to_s)  #hack.  Converting to strings for comparison to params hash

    new_relationships = new_agency_ids - old_agency_ids # Any agency set in the params but not the profile
    revoked_agencies = old_agency_ids - new_agency_ids # Any agency set in the profile but not the params
    new_relationships.each do |id| # Create new ones if they don't exist already
      rel = AgencyUserRelationship.find_or_create_by!(user_id: @user.id, agency_id: id) do |aur|
        aur.creator = current_user.id
      end
      #now that we have the relationship object, set it as active/confirmed
      rel.update_attributes(relationship_status: RelationshipStatus.confirmed)
      agency = Agency.find(id)
      UserMailer.agency_helping_email(@user.email, agency.email, agency)
    end
    revoked_agencies.each do |revoked_id|
      revoked = AgencyUserRelationship.find_by(agency_id: revoked_id, user_id: @user.id)
      revoked.update_attributes(relationship_status: RelationshipStatus.revoked)
    end
  end

  def set_booking_services(user, services)
    services.each do |id, user_id|
      service = Service.find(id)
      unless user_id == ""
        user_service = UserService.where(user_profile: user.user_profile, service: service).first_or_initialize
        user_service.external_user_id = user_id
        user_service.save
      else
        user_services = UserService.where(user_profile: user.user_profile, service: service)
        user_services.each do |user_service|
          user_service.destroy
        end
      end

    end
  end

end
