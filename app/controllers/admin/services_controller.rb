class Admin::ServicesController < Admin::BaseController
  include Admin::CommentsHelper

  before_filter :load_services
  before_filter :load_service, only: [:create]
  load_and_authorize_resource

  def index
  end

  # POST /admin/providers/:provider_id/services
  # load_service is called before this runs
  def create
    puts "CREATING SERVICE", params.ai
    @provider = Provider.find(params[:provider_id] || params[:service][:provider_id])
    @service.provider = @provider

    # Populate Service's Mode based on Service Type
    @service.update_attributes(mode: Mode.find_by_code("mode_#{@service.service_type.code}")) unless @service.service_type.nil?

    respond_to do |format|
      setup_comments(@service, %w{public}) # Set up comments -- makes sure there's a comment created for each locale
      @service.logo = params[:service][:logo] if params[:service][:logo]

      if @service.save
        puts "SERVICE SAVED", @service.ai
        # format.html { render partial: 'admin/services/services_menu' } # Refresh the whole services menu on successful create
        format.html { redirect_to edit_admin_provider_path(@provider), notice: "Service #{@service.name} was successfully created." } # Refresh whole page on successful create
        format.json { head :no_content }
      else
        puts "SERVICE NOT SAVED", @service.ai, @service.errors.ai
        format.html { render partial: params[:service_details_partial],
          locals: {new_service: true, service: @service, active: true, mode: @service.service_type.code},
          status: :partial_content }
      end
    end
  end

  # PATCH /admin/providers/:provider_id/services/:id
  def update
    puts "UPDATING SERVICE", params.ai
    @service = Service.find(params[:id])
    @provider = Provider.find(params[:provider_id] || params[:service][:provider_id])
    puts @service.ai

    respond_to do |format|
      @service.logo = params[:service][:logo] if params[:service][:logo]

      # Update Coverage Area Maps based on text input
      if params[:service][:primary_coverage_recipe]
        @primary_coverage = CoverageZone.build_coverage_area(params[:service][:primary_coverage_recipe])
        primary_coverage_errors = @primary_coverage.errors.messages.dup
        @service.update_attributes(primary_coverage: @primary_coverage)
      end

      if params[:service][:secondary_coverage_recipe]
        @secondary_coverage = CoverageZone.build_coverage_area(params[:service][:secondary_coverage_recipe])
        secondary_coverage_errors = @secondary_coverage.errors.messages.dup
        @service.update_attributes(secondary_coverage: @secondary_coverage)
      end

      # Update Booking Service Profile
      update_booking_service_profile unless params[:service][:booking_profile].nil?

      # Update Fare Structures
      update_fare unless params[:service][:base_fare_structure_attributes].nil?

      if @service.update_attributes(service_params)
        # Add coverage area errors after update so they show up in form error notification
        primary_coverage_errors.each {|k,v| @service.errors.add(k, v.first)} if primary_coverage_errors
        secondary_coverage_errors.each {|k,v| @service.errors.add(k, v.first)} if secondary_coverage_errors

        format.html { render partial: params[:service_details_partial],
          locals: {new_service: false, service: @service, active: true, mode: @service.service_type.code} }
        format.json { head :no_content }
      else
        puts "SERVICE UPDATE FAILED", @service.ai, @service.errors.ai
        format.html { render partial: params[:service_details_partial],
          locals: {new_service: false, service: @service, active: true, mode: @service.service_type.code},
          status: :partial_content }
      end
    end
  end

  protected

  def load_services
    @services = if params.include?(:provider_id)
      @services = Provider.find(params[:provider_id]).services
    else
      @services = Service.all(order: :name)
    end
  end

  # Initialize Service and perform setup actions as necessary
  def load_service
    @service = Service.new(service_params)
    @service.build_fare_structures_by_mode
    @service.setup_default_booking_cut_off_times
  end

  def update_booking_service_profile
    puts "Updating booking service profile", params[:service][:booking_profile]

    case params[:service][:booking_profile].to_i
    when BookingServices::AGENCY[:trapeze]
      update_trapeze_profile(params[:service][:trapeze_profile])
    when BookingServices::AGENCY[:ridepilot]
      update_ridepilot_profile(params[:service][:ridepilot_profile])
    when BookingServices::AGENCY[:ecolane]
      update_ecolane_profile(params[:service][:ecolane_profile])
    else
      puts "Invalid Booking Service"
    end
  end

  def update_trapeze_profile(trapeze_params)
    puts "Updating Trapeze Profile", trapeze_params.ai
    tp = TrapezeProfile.where(service: @service).first_or_initialize
    tp.para_service_id = trapeze_params[:para_service_id]
    tp.endpoint = trapeze_params[:endpoint]
    tp.namespace = trapeze_params[:namespace]
    tp.username = trapeze_params[:username]
    tp.password = trapeze_params[:password]
    tp.booking_offset_minutes = trapeze_params[:booking_offset_minutes].to_i
    tp.save
  end

  def update_ridepilot_profile(ridepilot_params)
    puts "Updating RidePilot Profile", ridepilot_params.ai
    rp = RidepilotProfile.where(service: @service).first_or_initialize
    rp.provider_id = ridepilot_params[:provider_id]
    rp.endpoint = ridepilot_params[:endpoint]
    rp.api_token = ridepilot_params[:api_token]
    rp.save
  end

  def update_ecolane_profile(ecolane_params)
    puts "Updating Ecolane Profile", ecolane_params.ai
    ep = EcolaneProfile.where(service: @service).first_or_initialize
    ep.system = ecolane_params[:system]
    ep.token = ecolane_params[:token]
    ep.disallowed_purposes_text = ecolane_params[:disallowed_purposes]
    ep.booking_counties_text = ecolane_params[:booking_counties]
    ep.api_version = ecolane_params[:api_version]
    ep.use_customer_default = (ecolane_params[:use_customer_default] == "true") ? true : false
    ep.save
  end

  def authenticate_booking_settings
    bs = BookingServices.new
    result = bs.authenticate_provider(params[:endpoint], params[:api_token], params[:provider_id], params[:booking_profile])

    if result[:authenticated]
      render json: {message: TranslationEngine.translate_text(:successful_connection)}
    else
      render json: {message: result[:message]}
    end
  end

  def update_fare
    if @service.fare_structures.count == 0
      @service.fare_structures.build
    end

    fs_attrs = params[:service][:base_fare_structure_attributes]

    if !fs_attrs[:id].blank?
      fs = FareStructure.find(fs_attrs[:id])
    else
      fs = @service.fare_structures.first
    end
    fs.fare_type = fs_attrs[:fare_type].to_i

    # Unless fare type is 4 (TFF), set taxi fare finder city to nil
    params[:service][:taxi_fare_finder_city] = nil unless fs.fare_type == FareStructure::TFF

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
      # If a new zone ID column and shapefile are included, create a new set of fare zones
      if params[:service][:fare_zone][:zone_id_column] && params[:service][:fare_zone][:file]

        file = params[:service][:fare_zone][:file]

        ZoneFare.where(fare_structure: fs).delete_all
        fs.zone_fares.clear
        FareZone.where(service: @service).delete_all
        @service.fare_zones.clear

        file_path = file.tempfile.path
        FareZone.parse_shapefile(params[:service][:fare_zone][:zone_id_column], file_path, @service)

        @zones = FareZone.where(service: @service).select(:id, :zone_id).order(:zone_id)
        @fares = {}
        @zones.each do |from_zone|
          @zones.each do |to_zone |
            from_zone_id = from_zone[:id]
            to_zone_id = to_zone[:id]
            @fares["from_#{from_zone_id}_to_#{to_zone_id}"] = {
              id: ZoneFare.create(
                from_zone_id: from_zone_id,
                to_zone_id: to_zone_id,
                fare_structure: fs
              ).id
            }
          end
        end
      end

      # zone fares
      zone_fares_attrs = params[:service][:zone_fares_attributes]

      if zone_fares_attrs
        zone_fares_attrs.each do | fare_attrs |
          next if fare_attrs[:rate].blank?
          fare_params = {
            rate: fare_attrs[:rate].to_f
          }

          fs.zone_fares.update_all fare_params, :id => fare_attrs[:id].to_i
        end
      end

      if fs.mileage_fare
        fs.mileage_fare.delete
        fs.mileage_fare = nil
      end

      if fs.flat_fare
        fs.flat_fare.delete
        fs.flat_fare = nil
      end
    when FareStructure::TFF
      # Taxi Fare Finder
    end

    fs.save
  end

  def service_params
    params.require(:service).permit(:name, :phone, :email, :url, :external_id, :public_comments_old, :private_comments_old,
                                    :booking_service_code, :advanced_notice_minutes, :active,
                                    :notice_days_part, :notice_hours_part, :notice_minutes_part, :max_advanced_book_minutes,
                                    :max_advanced_book_days_part, :max_advanced_book_hours_part, :max_advanced_book_minutes_part,
                                    :service_window, :time_factor, :provider_id, :service_type_id, :service_details_partial,
                                    :internal_contact_name, :internal_contact_title, :internal_contact_phone, :internal_contact_email,
                                    :taxi_fare_finder_city, :display_color, :disabled_comment, :booking_profile,
                                    :fleet_size, :trip_volume, :fare_info_url,
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
                                      [ :id, :base, :rate, :fare_type, public_comments_attributes: COMMENT_ATTRIBUTES ] },
                                    comments_attributes: COMMENT_ATTRIBUTES,
                                    public_comments_attributes: COMMENT_ATTRIBUTES,
                                    private_comments_attributes: COMMENT_ATTRIBUTES
                                    )
  end

end
