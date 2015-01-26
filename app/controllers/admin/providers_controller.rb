class Admin::ProvidersController < ApplicationController
  include Admin::CommentsHelper
  before_filter :load_provider, only: [:create]
  load_and_authorize_resource

  # GET /admin/providers
  # GET /admin/providers.json
  def index

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @providers }
    end
  end

  # GET /admin/providers/1
  # GET /admin/providers/1.json
  def show
    @providers = Provider.order(name: :asc).to_a

    # assume only one internal contact for now
    @contact = @provider.users.with_role(:internal_contact, @provider).first
    @staff = @provider.users.with_role(:provider_staff, @provider)
    @services = @provider.services

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @provider }
    end
  end

  # GET /admin/providers/new
  # GET /admin/providers/new.json
  def new
    # before_filter
    setup_comments(@provider)
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @provider }
    end
  end

  # POST /admin/providers
  # POST /admin/providers.json
  def create
    # before_filter
    # @provider = Provider.new(admin_provider_params)

    respond_to do |format|
      if @provider.save
        format.html { redirect_to [:admin, @provider], notice: 'Provider was successfully created.' } #TODO Internationalize
        format.json { render json: @provider, status: :created, location: @provider }
      else
        format.html { render action: "new" }
        format.json { render json: @provider.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /admin/providers/1/edit
  def edit
    # assume only one internal contact for now
    @contact = @provider.users.with_role(:internal_contact, @provider).first
    @staff = @provider.users.with_role(:provider_staff, @provider)
    setup_comments(@provider)
  end

  # PUT /admin/providers/1
  # PUT /admin/providers/1.json
  def update

    # special case because need to update rolify
    staff_ids = params[:provider][:staff_ids].split(',').reject(&:blank?)

    # TODO This is a little hacky for the moment; might switch to front-end javascript but let's just do this for now.
    fixup_comments_attributes_for_delete :provider

    respond_to do |format|
      if @provider.update_attributes(admin_provider_params)
        # internal_contact is a special case
        @provider.internal_contact = User.find_by_id(params[:provider][:internal_contact])

        if params[:provider][:logo]
          @provider.logo = params[:provider][:logo]
          @provider.save
        elsif params[:provider][:remove_logo] == '1' #confirm to delete it
          @provider.remove_logo!
          @provider.save
        end

        set_staff(staff_ids)

        format.html { redirect_to [:admin, @provider], notice: t(:provider) + ' ' + t(:was_successfully_updated) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @provider.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/providers/1
  # DELETE /admin/providers/1.json
  def destroy
    @provider.update_attributes(active: false)
    @provider.services.update_all(active: false)
    respond_to do |format|
      format.html { redirect_to admin_providers_url }
      format.json { head :no_content }
    end
  end

  def undelete
    @provider = Provider.find(params[:id])
    @provider.update_attributes(active: true)
    @provider.services.update_all(active: true)
    respond_to do |format|
      format.html { redirect_to admin_provider_path(@provider) }
      format.json { head :no_content }
    end
  end

  def find_staff_by_email
    user = User.staff_assignable.where("lower(email) = ?", params[:email].downcase).first #case insensitive

    if user.nil?
      success = false
      msg = I18n.t(:no_staff_with_email_address, email: params[:email]) # did you know that this was an XSS vector?  OOPS
    elsif !user.provider.nil?
      success = false
      msg = I18n.t(:already_a_provider_staff)
    else
      success = true
      msg = t(:please_save_staffs, name: user.name)
      output = user.id
      row = [
              user.id,
              user.name,
              user.title,
              user.phone,
              user.email
            ]
    end
    respond_to do |format|
      format.js { render json: {output: output, msg: msg, success: success, user_id: user.try(:id), row: row} }
    end
  end

  private

  def set_staff users
    # array of strings for comparison
    current_staff = @provider.users.pluck(:id).map(&:to_s)

    new_user_list = users.reject(&:blank?)

    users_to_add = new_user_list - current_staff
    users_to_remove = current_staff - new_user_list

    users_to_add.each do |u|
      user_to_add = User.find(u)
      user_to_add.add_role(:provider_staff, @provider)
      user_to_add.update_attributes(provider: @provider)
      @provider.users << user_to_add
    end

    users_to_remove.each do |u|
      user_to_remove = User.find(u)
      user_to_remove.remove_role(:provider_staff, @provider)
      if (user_to_remove.roles & @provider.roles).eql? []
        user_to_remove.update_attributes(provider: nil)
      end
    end
  end

  def admin_provider_params
    params.require(:provider).permit(:name, :email, :address, :city, :state, :zip, :url, :phone,
      :internal_contact_name, :internal_contact_title, :internal_contact_phone, :internal_contact_email,
      :public_comments_old, :private_comments_old,
      comments_attributes: COMMENT_ATTRIBUTES,
      public_comments_attributes: COMMENT_ATTRIBUTES,
      private_comments_attributes: COMMENT_ATTRIBUTES,
      )
  end

  def load_provider
    @provider = Provider.new(admin_provider_params)
  end

end
