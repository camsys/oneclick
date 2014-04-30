class ServicesController < ApplicationController
  load_and_authorize_resource
  include ApplicationHelper

  def index
    @services = Service.order(:name).to_a
  end

  def show
    @services = Service.order(:name).to_a
    if params['service']
      params[:id] = params['service']['id']
    end

    @service = Service.find(params[:id])
    @contact = @service.internal_contact
    
    polylines = {}
    ['origin', 'destination', 'residence'].each do |rule|
      coverages = @service.service_coverage_maps.where(rule: rule).type_polygon.first
      polylines[rule] = []
      if coverages
        geometry = Boundary.find(3).geom
        polylines[rule] << {
          "id" => 0,
          "geom" => geometry,
          "options" =>  {"color" => 'red', "width" => "5"}
        }
      end
    end
    @polylines = {}
    @polylines['origin'] = polylines['origin'].to_json || nil
    @polylines['destination'] = polylines['destination'].to_json || nil
    @polylines['residence'] = polylines['residence'].to_json || nil

    @eh = EligibilityService.new
    respond_to do |format|
      format.html
      format.json { render json: @service }
    end

  end

  # GET /services/new
  def new
    @service = Service.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @admin_provider }
    end
  end

    # GET /services/1/edit
  def edit
    @service = Service.find(params[:id])
    @contact = @service.internal_contact
    
    @schedules = []
    @service.schedules.each {|s| @schedules[s.day_of_week] = s}
    
    @staff = User.with_role(:provider_staff, @service.provider)
    @eh = EligibilityService.new
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

        format.html { redirect_to @service, notice: t(:service) + ' ' + t(:was_successfully_updated) } 
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @admin_provider.errors, status: :unprocessable_entity }
      end
    end
  end

  def service_params
    params.require(:service).permit(:name, :phone, :email, :url, :external_id,
                                    :booking_service_code, :advanced_notice_minutes,
                                    { schedules_attributes:
                                      [ :day_of_week, :start_time, :end_time, :id, :_destroy ] },
                                    { service_characteristics_attributes:
                                      [ :id, :active, :characteristic_id, :group, :value,
                                        :value_relationship_id, :_destroy ] },
                                    { accommodation_ids: [] },
                                    { trip_purpose_ids: [] })
  end

end
