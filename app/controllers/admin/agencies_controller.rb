class Admin::AgenciesController < Admin::OrganizationsController
  before_filter :load_agency, only: [:create]
  load_and_authorize_resource except: [:travelers]
  load_and_authorize_resource :id_param => :agency_id,  only: :travelers #TODO implies a refactor needed


  # GET /agencies/1/travelers
  def travelers
    @pre_auth_travelers = @agency.customers

    if params[:text] && params[:text].present?
      @found_travelers = (User.where('upper(first_name) LIKE ? OR upper(last_name) LIKE ? OR upper(email) LIKE ?', 
              "%#{params[:text].upcase}%", "%#{params[:text].upcase}%", "%#{params[:text].upcase}%")).uniq  #merge in the found users
    end
  end

  # GET /agencies
  # GET /agencies.json
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @agencies }
    end
  end

  # GET /agencies/1
  # GET /agencies/1.json
  def show
    puts @agency.id

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @agency }
    end
  end

  # GET /agencies/new
  # GET /agencies/new.json
  def new
    puts @agency.id
    # @agency = Agency.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @agency }
    end
  end

  # GET /agencies/1/edit
  def edit
    puts @agency.id
    # @agency = Agency.find(params[:id])
  end

  # POST /agencies
  # POST /agencies.json
  def create
    puts @agency.id
    params[:agency][:parent] = Agency.find(params[:agency].delete :parent_id) rescue nil
    # @agency = Agency.new(params[:agency])

    respond_to do |format|
      if @agency.save
        format.html { redirect_to [:admin, @agency], notice: 'Agency was successfully created.' }
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
    puts @agency.id
    # params[:agency][:parent] = Agency.find(params[:agency].delete :parent_id)
    # puts params[:agency][:parent].ai
    # @agency = Agency.find(params[:id])

    puts agency_params(params).ai
    
    respond_to do |format|
      if @agency.update_attributes!(agency_params(params))
        puts @agency.ai
        format.html { redirect_to [:admin, @agency], notice: 'Agency was successfully updated.' }
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
    puts @agency.id
    # @agency = Agency.find(params[:id])
    @agency.destroy

    respond_to do |format|
      format.html { redirect_to admin_agencies_path }
      format.json { head :no_content }
    end
  end
end

private

def agency_params params
  params.require(:agency).permit(:name, :parent_id, :parent)
end

def load_agency
  @agency = Agency.new(agency_params(params))
end
