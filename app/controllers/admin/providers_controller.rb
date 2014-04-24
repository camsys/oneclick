class Admin::ProvidersController < ApplicationController
  load_and_authorize_resource
  # GET /admin/providers
  # GET /admin/providers.json
  def index
    @admin_providers = Provider.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @admin_providers }
    end
  end

  # GET /admin/providers/1
  # GET /admin/providers/1.json
  def show
    @admin_provider = Provider.find(params[:id])
    @providers = Provider.order(name: :asc).to_a

    # assume only one internal contact for now
    @contact = @admin_provider.users.with_role(:internal_contact, @admin_provider).first
    @staff = @admin_provider.users.with_role(:provider_staff, @admin_provider)
    @services = @admin_provider.services
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @provider }
    end
  end

  # GET /admin/providers/new
  # GET /admin/providers/new.json
  def new
    @admin_provider = Provider.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @admin_provider }
    end
  end

  # GET /admin/providers/1/edit
  def edit
    @admin_provider = Provider.find(params[:id])
  end

  # POST /admin/providers
  # POST /admin/providers.json
  def create
    @admin_provider = Provider.new(okay_params)

    respond_to do |format|
      if @admin_provider.save
        format.html { redirect_to [:admin, @admin_provider], notice: 'Provider was successfully created.' } #TODO Internationalize
        format.json { render json: @admin_provider, status: :created, location: @admin_provider }
      else
        format.html { render action: "new" }
        format.json { render json: @admin_provider.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /admin/providers/1
  # PUT /admin/providers/1.json
  def update
    @admin_provider = Provider.find(params[:id])

    respond_to do |format|
      if @admin_provider.update_attributes(okay_params)
        format.html { redirect_to [:admin, @admin_provider], notice: 'Provider was successfully updated.' } #TODO Internationalize
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @admin_provider.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/providers/1
  # DELETE /admin/providers/1.json
  def destroy
    @admin_provider = Provider.find(params[:id])
    @admin_provider.destroy

    respond_to do |format|
      format.html { redirect_to admin_providers_url }
      format.json { head :no_content }
    end
  end

  private

  def okay_params
    params.require(:admin_provider).permit(:name) ##TODO Bring in line with data reqs
  end

end
