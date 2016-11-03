class Admin::ServicesController < Admin::BaseController
  before_filter :load_services
  before_filter :load_service, only: [:create]
  load_and_authorize_resource

  def index
  end

  # POST /admin/providers/:provider_id/services
  def create
    puts "CREATE NEW SERVICE", params.ai
    # already done by load_service
    # @service = Service.new(service_params)

    @provider = Provider.find(params[:provider_id] || params[:service][:provider_id])
    @service.provider = @provider
    @service.fare_structures.build

    respond_to do |format|
      puts "RESPONDING TO CREATE REQUEST", request.format.html?

      @service.logo = params[:service][:logo] if params[:service][:logo]

      if @service.save
        puts "SERVICE SAVED"
        format.html { render partial: 'admin/services/services_menu' }
        format.json { head :no_content }
      else
        puts "SERVICE NOT SAVED"

        # format.html { render partial: 'service_form_mode_paratransit', notice: 'Service not added.' }
        format.json { render json: @service.errors, status: :unprocessable_entity }
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
      @service.update_attributes(primary_coverage: CoverageZone.build_coverage_area(params[:service][:primary_coverage_recipe])) if params[:service][:primary_coverage_recipe]
      @service.update_attributes(secondary_coverage: CoverageZone.build_coverage_area(params[:service][:secondary_coverage_recipe])) if params[:service][:secondary_coverage_recipe]

      # Update Booking Service Profile
      update_booking_service_profile

      # Update Fare Structures
      update_fare

      if @service.update_attributes(service_params)
        puts "SERVICE UPDATED", @service.ai
        format.html { render partial: params[:service_details_partial], locals: {new_service: false, service: @service, active: true} }
        format.json { head :no_content }
      else
        puts "SERVICE UPDATE FAILED"
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

  def load_service
    @service = Service.new(service_params)
    puts "LOADING SERVICE", @service.ai
  end

  def update_booking_service_profile
    puts "Updating booking service profile", params[:service][:booking_profile]

    case params[:service][:booking_profile].to_i
    when BookingServices::AGENCY[:trapeze]
      update_trapeze_profile(params[:service][:trapeze_profile])
    when BookingServices::AGENCY[:ridepilot]
      update_ridepilot_profile(params[:service][:ridepilot_profile])
    when BookingServices::AGENCY[:ecolane]
      puts "Ecolane!"
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

  def service_params
    params.require(:service).permit(:name, :phone, :email, :url, :external_id, :public_comments_old, :private_comments_old,
                                    :booking_service_code, :advanced_notice_minutes, :active,
                                    :notice_days_part, :notice_hours_part, :notice_minutes_part, :max_advanced_book_minutes,
                                    :max_advanced_book_days_part, :max_advanced_book_hours_part, :max_advanced_book_minutes_part,
                                    :service_window, :time_factor, :provider_id, :service_type_id, :service_details_partial,
                                    :internal_contact_name, :internal_contact_title, :internal_contact_phone, :internal_contact_email,
                                    :taxi_fare_finder_city, :display_color, :disabled_comment, :booking_profile,
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
                                    { service_coverage_maps_attributes:
                                      [ :id, :rule, :geo_coverage_id, :_destroy, :keep_record ] },
                                    comments_attributes: COMMENT_ATTRIBUTES,
                                    public_comments_attributes: COMMENT_ATTRIBUTES,
                                    private_comments_attributes: COMMENT_ATTRIBUTES
                                    )
  end

end
