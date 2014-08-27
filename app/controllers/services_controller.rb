class ServicesController < ApplicationController
  before_filter :load_service, only: [:create]
  load_and_authorize_resource
  
  include ApplicationHelper

  def index
    @services = Service.order(:name)
  end

  def show
    @services = Service.order(:name).to_a
    if params['service']
      params[:id] = params['service']['id']
    end

    @service = Service.find(params[:id])
    @contact = @service.internal_contact
    
    polylines = []

    ['coverage_area', 'endpoint_area'].each do |rule|
      case rule
        when 'coverage_area'
          geometry = @service.coverage_area_geom.try(:geom)
          color = 'red'
          id = 1
        when 'endpoint_area'
          geometry = @service.endpoint_area_geom.try(:geom)
          color = 'green'
          id = 0
      end

      unless geometry.nil?
        polylines << {
           "id" => id,
           "geom" => @service.wkt_to_array(rule),
           "options" =>  {"color" => color, "width" => "2"}
        }
      end
    end

    @polylines = polylines.to_json || nil

    @eh = EligibilityService.new
    respond_to do |format|
      format.html
      format.json { render json: @service }
    end

  end

  # GET /services/new
  def new
    @service = Service.new
    # Have to specify a provider to create a service for
    @provider = Provider.find(params[:provider_id])

    # TODO: handle bogus provider
    @service.provider = @provider

    set_aux_instance_variables

    @service.fare_structures.build

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @admin_provider }
    end
  end

  # POST /services
  # POST /services.json
  def create
    # already done by load_service
    # @service = Service.new(service_params)

    @provider = Provider.find(params[:provider_id])
    @service.provider = @provider    

    respond_to do |format|
      if @service.save
        @service.build_polygons
        format.html { redirect_to [:admin, @provider], notice: 'Service was successfully added.' } #TODO Internationalize
        format.json { render json: @service, status: :created, location: @service }
      else

        set_aux_instance_variables

        @service.fare_structures.build

        format.html { render action: "new" }
        format.json { render json: @service.errors, status: :unprocessable_entity }
      end
    end
  end

    # GET /services/1/edit
  def edit
    @service = Service.find(params[:id])
    @contact = @service.internal_contact

    set_aux_instance_variables

    if @service.fare_structures.count < 1
      @service.fare_structures.build
    end
    
  end

  # PUT /services/1
  # PUT /services/1.json
  def update
    @service = Service.find(params[:id])

    respond_to do |format|
      par = service_params
      if @service.update_attributes(service_params)
        # internal_contact is a special case
        @service.internal_contact = User.find_by_id(params[:service][:internal_contact])
        @service.build_polygons
        if params[:service][:logo]
          @service.logo = params[:service][:logo] 
          @service.save!
        end

        format.html { redirect_to @service, notice: t(:service) + ' ' + t(:was_successfully_updated) } 
        format.json { head :no_content }
      else
        format.html {
          set_aux_instance_variables
          render action: "edit"
        }
        format.json { render json: @admin_provider.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /services/1
  # DELETE /services/1.json
  def destroy
    @service.active = false
    @service.save

    respond_to do |format|
      format.html { redirect_to admin_provider_path @service.provider }
      format.json { head :no_content }
    end
  end
    
protected
  def service_params
    params.require(:service).permit(:name, :phone, :email, :url, :external_id, :public_comments, :private_comments,
                                    :booking_service_code, :advanced_notice_minutes,
                                    :notice_days_part, :notice_hours_part, :notice_minutes_part,
                                    :service_window, :time_factor, :provider_id, :service_type_id,
                                    :internal_contact_name, :internal_contact_title, :internal_contact_phone, :internal_contact_email,
                                    { schedules_attributes:
                                      [ :day_of_week, :start_time, :end_time, :id, :_destroy ] },
                                    { service_characteristics_attributes:
                                      [ :id, :active, :characteristic_id, :group, :value,
                                        :rel_code, :_destroy ] },
                                    { accommodation_ids: [] },
                                    { trip_purpose_ids: [] },
                                    { fare_structures_attributes:
                                      [ :id, :base, :rate, :desc ] },
                                    { service_coverage_maps_attributes:
                                      [ :id, :rule, :geo_coverage_id, :_destroy, :keep_record ] }
                                    )
  end

  def load_service
    @service = Service.new(service_params)
  end

  def set_aux_instance_variables
    @schedules = []
    @service.schedules.each {|s| @schedules[s.day_of_week] = s}
    
    @staff = User.with_role(:provider_staff, @service.provider)
    @eh = EligibilityService.new

  end
  
end
