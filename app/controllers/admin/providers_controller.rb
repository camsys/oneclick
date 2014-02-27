class Admin::ProvidersController < ApplicationController
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
    @provider = Provider.find(params[:id])

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
    @admin_provider = Provider.new(params[:admin_provider])

    respond_to do |format|
      if @admin_provider.save
        format.html { redirect_to [:admin, @admin_provider], notice: 'Provider org was successfully created.' }
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
      if @admin_provider.update_attributes(params[:admin_provider])
        format.html { redirect_to [:admin, @admin_provider], notice: 'Provider org was successfully updated.' }
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
end
