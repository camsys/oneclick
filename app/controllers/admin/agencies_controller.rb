class Admin::AgenciesController < ApplicationController
  include Admin::CommentsHelper
  include CsvStreaming

  before_filter :load_agency, only: [:create]
  load_and_authorize_resource except: [:travelers, :find_agent_by_email]
  load_and_authorize_resource :id_param => :agency_id,  only: :travelers #TODO implies a refactor needed

  # GET /agencies
  # GET /agencies.json
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @agencies }
      format.csv do
        filter_params = params.permit(:bIncludeInactive, :search)

        @agencies = Agency.get_exported(@agencies, filter_params)

        render_csv("agencies.csv", @agencies, Agency.csv_headers)
      end
    end
  end

   # GET /agencies/1/travelers
  def travelers
    @pre_auth_travelers = @agency.customers

    respond_to do |format|
      format.html # travelers.html.erb
      format.json { render json: @pre_auth_travelers }
    end
  end

  # GET /agencies/1
  # GET /agencies/1.json
  def show
    # assume only one internal contact for now
    @contact = @agency.users.with_role(:internal_contact, @agency).first
    @admins = @agency.administrators
    @agents = @agency.agents

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @agency }
    end
  end

  # GET /agencies/new
  # GET /agencies/new.json
  def new
    # @agency = Agency.new
    setup_comments(@agency)
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @agency }
    end
  end

  # GET /agencies/1/edit
  def edit

    @contact = @agency.internal_contact
    @addable_users = User.staff_assignable
    # @agency = Agency.find(params[:id])
    setup_comments(@agency)
  end

  # POST /agencies
  # POST /agencies.json
  def create
    params[:agency][:parent] = Agency.find(params[:agency].delete :parent_id) rescue nil
    # @agency = Agency.new(params[:agency])

    respond_to do |format|
      if @agency.save
        format.html { redirect_to [:admin, @agency], notice: TranslationEngine.translate_text(:agency_was_successfully_created) }
        format.json { render json: @agency, status: :created, location: @agency }
      else
        format.html { render action: "new" }
        format.json { render json: @agency.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /agencies/1
  # PUT /agencies/1.json
  def update
    internal_contact_id = params[:agency][:internal_contact] # as this isn't an attribute, have to pull it before Strong Params
    agent_ids = params[:agency][:agent_ids].split(',').reject(&:blank?) #again, special case because need to update rolify
    admin_ids = params[:agency][:administrator_ids].reject(&:blank?) #again, special case because need to update rolify

    # TODO This is a little hacky for the moment; might switch to front-end javascript but let's just do this for now.
    fixup_comments_attributes_for_delete :agency

    Rails.logger.info "After params, is\n#{agency_params(params).ai}"
    respond_to do |format|
      if @agency.update_attributes!(agency_params(params))
        set_internal_contact(internal_contact_id) unless internal_contact_id.blank?
        set_agents(agent_ids)
        set_admins(admin_ids)
        format.html { redirect_to [:admin, @agency], notice: TranslationEngine.translate_text(:agency) + ' ' + TranslationEngine.translate_text(:was_successfully_updated) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @agency.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /agencies/1
  # DELETE /agencies/1.json
  def destroy
    # @agency = Agency.find(params[:id])
    @agency.disabled_comment = params[:agency][:disabled_comment]
    @agency.update_attributes(active: false)

    respond_to do |format|
      format.html { redirect_to admin_agencies_path }
      format.json { head :no_content }
    end
  end

  def undelete
    @agency = Agency.find(params[:id])
    @agency.update_attributes(active: true)
    respond_to do |format|
      format.html { redirect_to admin_agency_path(@agency) }
      format.json { head :no_content }
    end
  end

  def find_agent_by_email
    user = User.staff_assignable.where("lower(email) = ?", params[:email].downcase).first #case insensitive

    if user.nil?
      success = false
      msg = TranslationEngine.translate_text(:no_agent_with_email_address, email: params[:email]) # did you know that this was an XSS vector?  OOPS
    elsif !user.agency.nil?
      success = false
      msg = TranslationEngine.translate_text(:already_an_agency_agent)
    else
      success = true
      msg = TranslationEngine.translate_text(:please_save_agents, name: user.name)
      output = user.id
      row = [
              user.id,
              user.name,
              user.email
            ]
    end
    respond_to do |format|
      format.js { render json: {output: output, msg: msg, success: success, user_id: user.try(:id), row: row} }
    end
  end
end

private

def agency_params params
  params.require(:agency).permit(:name, :address, :city, :state, :zip, :phone, :email, :url,
    :parent_id, :parent,:internal_contact_name, :internal_contact_title, :internal_contact_phone,
    :internal_contact_email, :disabled_comment,
    comments_attributes: COMMENT_ATTRIBUTES,
    public_comments_attributes: COMMENT_ATTRIBUTES,
    private_comments_attributes: COMMENT_ATTRIBUTES,
    )
end

def load_agency
  @agency = Agency.new(agency_params(params))
end

#Are these model methods?

def set_internal_contact(id)
  @agency.internal_contact = User.find(id)
end

def set_agents (users)
  current_agents = @agency.agents.pluck(:id).map(&:to_s) #must be an array of strings for comparison
  new_user_list = users.reject(&:blank?)

  users_to_add = new_user_list - current_agents
  users_to_remove = current_agents - new_user_list

  users_to_add.each do |u|
    user_to_add = User.find(u)
    user_to_add.add_role(:agent, @agency)
    user_to_add.update_attributes(agency: @agency) #NOTE this will overwrite existing associations
    @agency.users << user_to_add
  end

  users_to_remove.each do |u|
    user_to_remove = User.find(u)
    user_to_remove.remove_role(:agent, @agency)
    if (user_to_remove.roles & @agency.roles).eql? []
      user_to_remove.update_attributes(agency: nil)
    end
  end
end

def set_admins (users)
  current_admins = @agency.administrators.pluck(:id).map(&:to_s) #must be an array of strings for comparison
  new_user_list = users.reject(&:blank?)

  users_to_add = new_user_list - current_admins
  users_to_remove = current_admins - new_user_list

  users_to_add.each do |u|
    user_to_add = User.find(u)
    user_to_add.add_role(:agency_administrator, @agency)
    user_to_add.update_attributes(agency: @agency) #NOTE this will overwrite existing associations
    @agency.users << user_to_add
  end

  users_to_remove.each do |u|
    user_to_remove = User.find(u)
    user_to_remove.remove_role(:agency_administrator, @agency)
    if (user_to_remove.roles & @agency.roles).eql? []
      user_to_remove.update_attributes(agency: nil)
    end
  end
end
