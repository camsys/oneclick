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
      @service.update_attributes(primary_coverage: CoverageZone.build_coverage_area(params[:service][:primary_coverage_recipe])) if params[:service][:primary_coverage]
      @service.update_attributes(secondary_coverage: CoverageZone.build_coverage_area(params[:service][:secondary_coverage_recipe])) if params[:service][:secondary_coverage]

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

  def service_params
    params.require(:service).permit(:name, :phone, :email, :url, :external_id, :public_comments_old, :private_comments_old,
                                    :booking_service_code, :advanced_notice_minutes, :active,
                                    :notice_days_part, :notice_hours_part, :notice_minutes_part, :max_advanced_book_minutes,
                                    :max_advanced_book_days_part, :max_advanced_book_hours_part, :max_advanced_book_minutes_part,
                                    :service_window, :time_factor, :provider_id, :service_type_id, :service_details_partial,
                                    :internal_contact_name, :internal_contact_title, :internal_contact_phone, :internal_contact_email, :taxi_fare_finder_city, :display_color, :disabled_comment, :booking_profile,
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
                                    trapeze_profile_attributes: [:para_service_id],
                                    comments_attributes: COMMENT_ATTRIBUTES,
                                    public_comments_attributes: COMMENT_ATTRIBUTES,
                                    private_comments_attributes: COMMENT_ATTRIBUTES
                                    )
  end

end
