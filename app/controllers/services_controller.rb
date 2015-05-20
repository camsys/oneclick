class ServicesController < ApplicationController
  include Admin::CommentsHelper
  include CsvStreaming

  before_filter :load_service, only: [:create]
  load_and_authorize_resource

  include ApplicationHelper

  def index
    @services = Service.order(:name)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @services }
      format.csv do
        filter_params = params.permit(:bIncludeInactive, :search)

        @services = Service.get_exported(@services, filter_params)

        render_csv("services.csv", @services, Service.csv_headers)
      end
    end
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

    #Set Default Values
    @service.phone = @provider.phone
    @service.email = @provider.email
    @service.url = @provider.url

    @service.internal_contact_name = @provider.internal_contact_name
    @service.internal_contact_title = @provider.internal_contact_title
    @service.internal_contact_phone = @provider.internal_contact_phone
    @service.internal_contact_email = @provider.internal_contact_email
    @contact = @provider.users.with_role(:internal_contact, @provider).first
    if @contact
      @service.users << @contact
    end

    # TODO: handle bogus provider
    @service.provider = @provider

    set_aux_instance_variables

    set_up_default_schedules

    @service.fare_structures.build

    setup_comments(@service)

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

    @provider = Provider.find(params[:provider_id] || params[:service][:provider_id])
    @service.provider = @provider
    @service.internal_contact = User.find_by_id(params[:service][:internal_contact])

    #hacking in the mode for now - have agreed with DE to revisit Mode issues soon after this release
    if @service.service_type.present? && @service.service_type.code == "taxi"
      taxi_mode = Mode.find_by_code("mode_taxi")
      @service.mode_id = taxi_mode.id
    end

    respond_to do |format|
      if @service.save
        @service.build_polygons
        format.html { redirect_to [:admin, @provider], notice: 'Service was successfully added.' } #TODO Internationalize
        format.json { render json: @service, status: :created, location: @service }
      else

        set_aux_instance_variables
        set_up_default_schedules
        @contact = @provider.users.with_role(:internal_contact, @provider).first
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
    setup_comments(@service)

  end

  # PUT /services/1
  # PUT /services/1.json
  def update
    # TODO This is a little hacky for the moment; might switch to front-end javascript but let's just do this for now.
    fixup_comments_attributes_for_delete :service

    @service = Service.find(params[:id])

    respond_to do |format|

      par = service_params

      if @service.update_attributes(service_params)

        #hacking in the mode for now - have agreed with DE to revisit Mode issues soon after this release
        if @service.service_type.code == "taxi"
          taxi_mode = Mode.find_by_code("mode_taxi")
          @service.mode_id = taxi_mode.id
        end

        # internal_contact is a special case
        @service.internal_contact = User.find_by_id(params[:service][:internal_contact])

        temp_endpoints_shapefile = params[:service][:endpoints_shapefile]
        temp_coverages_shapefile = params[:service][:coverages_shapefile]
        unless temp_endpoints_shapefile.nil?
          if temp_endpoints_shapefile.content_type.include?('zip')
            temp_endpoints_shapefile_path = temp_endpoints_shapefile.tempfile.path
          else
            zip_alert_msg = t(:upload_zip_alert)
          end
        end
        unless temp_coverages_shapefile.nil?
          if temp_coverages_shapefile.content_type.include?('zip')
            temp_coverages_shapefile_path = temp_coverages_shapefile.tempfile.path
          else
            zip_alert_msg = t(:upload_zip_alert)
          end
        end

        polygon_alert_msg = @service.build_polygons(temp_endpoints_shapefile_path, temp_coverages_shapefile_path)
        if params[:service][:logo]
          @service.logo = params[:service][:logo]
          @service.save
        elsif params[:service][:remove_logo] == '1' #confirm to delete it
          @service.remove_logo!
          @service.save
        end

        # fare
        if @service.is_paratransit?
          update_fare
        end

        alert_msgs = [zip_alert_msg, polygon_alert_msg].delete_if {|x| x == nil}

        if alert_msgs.count > 0
          format.html { redirect_to @service, alert: alert_msgs.join('; ') }
        else
          format.html { redirect_to @service, notice: t(:service) + ' ' + t(:was_successfully_updated) }
        end
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
    @service.disabled_comment = params[:service][:disabled_comment]
    @service.update_attributes(active: false)

    respond_to do |format|
      format.html { redirect_to service_path(@service) }
      format.json { head :no_content }
    end
  end

  def undelete
    @service = Service.find(params[:id])
    @service.update_attributes(active: true)

    respond_to do |format|
      format.html { redirect_to service_path(@service) }
      format.json { head :no_content }
    end
  end

  def fare_type_form
    service = Service.find(params[:id])

    @fare_type = params[:fare_type].to_i if !params[:fare_type].blank?
    if service.fare_structures.count > 0
      @fare_structure = service.fare_structures.first
    else
      @fare_structure = service.fare_structures.build(fare_type: @fare_type)
    end

    respond_to do |format|
      format.js
    end
  end

protected
  def service_params
    params.require(:service).permit(:name, :phone, :email, :url, :external_id, :public_comments_old, :private_comments_old,
                                    :booking_service_code, :advanced_notice_minutes,
                                    :notice_days_part, :notice_hours_part, :notice_minutes_part, :max_advanced_book_minutes,
                                    :max_advanced_book_days_part, :max_advanced_book_hours_part, :max_advanced_book_minutes_part,
                                    :service_window, :time_factor, :provider_id, :service_type_id,
                                    :internal_contact_name, :internal_contact_title, :internal_contact_phone, :internal_contact_email, :taxi_fare_finder_city, :display_color, :disabled_comment,
                                    { schedules_attributes:
                                      [ :day_of_week, :start_time, :end_time, :id, :_destroy ] },
                                    { booking_cut_off_times_attributes:
                                      [ :day_of_week, :cut_off_time, :id, :_destroy ] },
                                    { service_characteristics_attributes:
                                      [ :id, :active, :characteristic_id, :group, :value,
                                        :rel_code, :_destroy ] },
                                    { accommodation_ids: [] },
                                    { trip_purpose_ids: [] },
                                    { fare_structures_attributes:
                                      [ :id, :base, :rate, :desc, :fare_type ] },
                                    { service_coverage_maps_attributes:
                                      [ :id, :rule, :geo_coverage_id, :_destroy, :keep_record ] },
                                    comments_attributes: COMMENT_ATTRIBUTES,
                                    public_comments_attributes: COMMENT_ATTRIBUTES,
                                    private_comments_attributes: COMMENT_ATTRIBUTES
                                    )
  end

  def load_service
    @service = Service.new(service_params)
  end

  def set_aux_instance_variables
    @schedules = []
    @service.schedules.each {|s| @schedules[s.day_of_week] = s}

    @cut_off_times = []
    @service.booking_cut_off_times.each {|s| @cut_off_times[s.day_of_week] = s}

    @staff = User.with_role(:provider_staff, @service.provider)
    @eh = EligibilityService.new

  end

  # when create a new service, default schedule is 24 * 7
  def set_up_default_schedules
    (0..6).each do |day_of_week|
      @schedules[day_of_week] = Schedule.new({
        day_of_week: day_of_week,
        start_seconds: 0,
        end_seconds: 24 * 60 * 60 -1,
        service_id: @service.id
        })
    end
  end

  def update_fare
    if @service.fare_structures.count == 0
      @service.fare_structures.build
    end

    fs_attrs = service_params[:fare_structures_attributes]
    if fs_attrs[:id]
      fs = FareStructure.find(fs_attrs[:id])
    else
      fs = @service.fare_structures.first
    end
    fs.fare_type == fs_attrs[:fare_type].to_i

    case fs.fare_type
    when FareStructure::FLAT
      # flat fare
      flat_fare_attrs = params[:service][:flat_fare_attributes]
      flat_fare_params = {
        fare_structure: fs,
        one_way_rate: (flat_fare_attrs[:one_way_rate].to_f if !flat_fare_attrs[:one_way_rate].blank?),
        round_trip_rate: (flat_fare_attrs[:round_trip_rate].to_f if !flat_fare_attrs[:round_trip_rate].blank?)
      }
      if !fs.flat_fare
        FlatFare.create flat_fare_params
      else
        fs.flat_fare.update_attributes flat_fare_params
      end

      if fs.mileage_fare
        fs.mileage_fare.delete
        fs.mileage_fare = nil
      end
      fs.zone_fares.update_all(:rate => nil)
    when FareStructure::MILEAGE
      # mileage fare
      mileage_fare_attrs = params[:service][:mileage_fare_attributes]
      mileage_fare_params = {
        fare_structure: fs,
        base_rate: (mileage_fare_attrs[:base_rate].to_f if !mileage_fare_attrs[:base_rate].blank? ),
        mileage_rate: (mileage_fare_attrs[:mileage_rate].to_f if !mileage_fare_attrs[:mileage_rate].blank?)
      }
      if !fs.mileage_fare
        MileageFare.create mileage_fare_params
      else
        fs.mileage_fare.update_attributes mileage_fare_params
      end

      fs.zone_fares.update_all(:rate => nil)
      if fs.flat_fare
        fs.flat_fare.delete
        fs.flat_fare = nil
      end
    when FareStructure::ZONE
      # zone fares
      zone_fares_attrs = params[:service][:zone_fares_attributes]

      zone_fares_attrs.each do | fare_attrs |
        next if fare_attrs[:rate].blank?
        fare_params = {
          rate: fare_attrs[:rate].to_f
        }

        fs.zone_fares.update_all fare_params, :id => fare_attrs[:id].to_i
      end

      if fs.mileage_fare
        fs.mileage_fare.delete
        fs.mileage_fare = nil
      end

      if fs.flat_fare
        fs.flat_fare.delete
        fs.flat_fare = nil
      end
    end

    fs.save
  end

end
