class Admin::ProviderOrgsController < ApplicationController
  # GET /admin/provider_orgs
  # GET /admin/provider_orgs.json
  def index
    @provider_orgs = ProviderOrg.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @provider_orgs }
    end
  end

  # GET /admin/provider_orgs/1
  # GET /admin/provider_orgs/1.json
  def show
    @provider_org = ProviderOrg.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @provider_org }
    end
  end

  # GET /admin/provider_orgs/new
  # GET /admin/provider_orgs/new.json
  def new
    @provider_org = ProviderOrg.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @provider_org }
    end
  end

  # GET /admin/provider_orgs/1/edit
  def edit
    @provider_org = ProviderOrg.find(params[:id])
  end

  # POST /admin/provider_orgs
  # POST /admin/provider_orgs.json
  def create
    @provider_org = ProviderOrg.new(params[:provider_org])

    respond_to do |format|
      if @provider_org.save
        format.html { redirect_to [:admin, @provider_org], notice: 'Provider org was successfully created.' }
        format.json { render json: @provider_org, status: :created, location: @provider_org }
      else
        format.html { render action: "new" }
        format.json { render json: @provider_org.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /admin/provider_orgs/1
  # PUT /admin/provider_orgs/1.json
  def update
    @provider_org = ProviderOrg.find(params[:id])

    respond_to do |format|
      if @provider_org.update_attributes(params[:provider_org])
        format.html { redirect_to [:admin, @provider_org], notice: 'Provider org was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @provider_org.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/provider_orgs/1
  # DELETE /admin/provider_orgs/1.json
  def destroy
    @provider_org = ProviderOrg.find(params[:id])
    @provider_org.destroy

    respond_to do |format|
      format.html { redirect_to admin_provider_orgs_url }
      format.json { head :no_content }
    end
  end
end
