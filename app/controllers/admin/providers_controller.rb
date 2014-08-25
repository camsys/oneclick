class Admin::ProvidersController < ApplicationController
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
  end

  # PUT /admin/providers/1
  # PUT /admin/providers/1.json
  def update
    
    # special case because need to update rolify
    staff_ids = params[:provider][:staff_ids].reject(&:blank?) 

    respond_to do |format|
      if @provider.update_attributes(admin_provider_params)
        # internal_contact is a special case
        @provider.internal_contact = User.find_by_id(params[:provider][:internal_contact])

        set_staff(staff_ids)
        
        format.html { redirect_to [:admin, @provider], notice: 'Provider was successfully updated.' } #TODO Internationalize
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
    @provider.active = false
    @provider.save
    @provider.services.update_all(active: false)
    respond_to do |format|
      format.html { redirect_to admin_providers_url }
      format.json { head :no_content }
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
    params.require(:provider).permit(:name, :email, :address, :city, :state, :zip, :url, :phone, :internal_contact_name, :internal_contact_title, :internal_contact_phone, :internal_contact_email, :public_comments, :private_comments)
  end

  def load_provider
    @provider = Provider.new(admin_provider_params)
  end
  
end
