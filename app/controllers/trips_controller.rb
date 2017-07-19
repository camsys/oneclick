class TripsController < PlaceSearchingController
  # set the @trip variable before any actions are invoked
  before_filter :get_trip, :only => [:show, :email, :email_itinerary, :details, :repeat, :edit, :multi_od_grid,
    :destroy, :update, :itinerary, :hide, :unhide_all, :select, :email_itinerary2_values, :email2,
    :show_printer_friendly, :example, :plan, :populate, :book, :itinerary_map, :print_itinerary_map]
  load_and_authorize_resource only: [:new, :create, :show, :index, :update, :edit]

  include ItineraryHelper
  before_action :detect_ui_mode, :get_trip_purposes, :get_ecolane_trip_purposes

  def index

    # trip_view
    q_param = params[:q]
    page = params[:page]
    @per_page = params[:per_page] || Kaminari.config.default_per_page

    @q = TripView.ransack q_param
    @q.sorts = "id asc" if @q.sorts.empty?

    @params = {q: q_param}
    total_trips = @q.result(:district => true)

    # filter data based on accessibility
    total_trips = total_trips.by_user(params[:user_id])

    # @results is for html display; only render current page
    @trip_views = total_trips.page(page).per(@per_page)
    @trips = Trip.where(id: @trip_views.pluck(:id))

    # If any itineraries are booked, update their statuses
    @itineraries = []
    @trips.each do |trip|
      @itineraries += trip.itineraries.booked
    end
    @itineraries.each do |itinerary|
      itinerary.update_booking_status
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @trips }
    end

  end

  def show
    trip_serialization(params)

    max_walk_dist =  @traveler.walking_maximum_distance || WalkingMaximumDistance.where(is_default:true).first
    unless max_walk_dist.nil?
      @max_walk_dist_value = max_walk_dist.value
    end

    @max_wait_time =  @traveler.max_wait_time

    @max_paratransit_count =  Oneclick::Application.config.max_number_of_specialized_services_to_show

    @current_user_accommodations = []
    User.find(params[:user_id]).user_accommodations.where(value: "true").each do |acc|
      @current_user_accommodations << TranslationEngine.translate_text(Accommodation.find(acc.accommodation_id).name).downcase
    end

    @satisfaction_survey = SatisfactionSurvey.new

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @tripResponse }
    end
  end

  # showing plan_a_trip page for multi-od
  # agent only
  def create_multi_od
    authorize! :manage, MultiOriginDestTrip

    session[:is_multi_od] = true
    session[:multi_od_trip_id] = nil
    session[:multi_od_trip_edited] = false

    new_trip

    if session[:is_multi_od] == true
      @selected_modes = Mode.all_transit_modes.concat(Mode.transit.submodes).collect{|m| m.code}.uniq
    end

    respond_to do |format|
      format.html { render action: "new" }# new.html.erb
      format.json { render json: @trip_proxy }
    end
  end

  # showing a grid summary of each O-D trip for multi-OD trip planning
  # agent only
  def multi_od_grid
    session[:is_multi_od] = true
    authorize! :manage, MultiOriginDestTrip

    @trip = Trip.find(params[:trip_id]) # base trip
    session[:multi_od_trip_id] = session[:multi_od_trip_id] || params[:multi_od_trip_id]
    @multi_od_trip = MultiOriginDestTrip.find(session[:multi_od_trip_id])

    unless @multi_od_trip.nil?
      origin_places = @multi_od_trip.origin_places.split(';##$##;')
      dest_places = @multi_od_trip.dest_places.split(';##$##;')

      if @multi_od_trip.trips.length == 0 || session[:multi_od_trip_edited] == true
        @multi_od_trip.trips = []

        trip_proxy = create_trip_proxy(@trip, modes: session[:modes_desired])
        trip_proxy.traveler = @traveler
        origin_places.each do |origin_place|
          origin_obj = JSON.parse(origin_place)
          dest_places.each do |dest_place|
            dest_obj = JSON.parse(dest_place)

            trip_proxy.from_place = origin_obj["name"]
            trip_proxy.to_place = dest_obj["name"]
            if origin_obj["is_full"] == true
              trip_proxy.from_place_object = origin_obj["data"].to_json
            else
              trip_proxy.from_place_object = nil
            end

            if dest_obj["is_full"] == true
              trip_proxy.to_place_object = dest_obj["data"].to_json
            else
              trip_proxy.to_place_object = nil
            end

            new_trip = Trip.create_from_proxy(trip_proxy, current_or_guest_user, @traveler)
            if new_trip && new_trip.errors.empty? && new_trip.save
              #new_trip.create_itineraries
              @multi_od_trip.trips << new_trip
            end
          end
        end

        @multi_od_trip.save
      end

      @origin_place_names = []
      @dest_place_names = []
      @multi_od_trip.trips.each do |trip|
        @origin_place_names << trip.trip_places.first.name
        @dest_place_names << trip.trip_places.last.name
      end

      session[:multi_od_trip_edited] = false
    else
      flash.now[:alert] = TranslationEngine.translate_text(:something_went_wrong)
    end

    respond_to do |format|
      format.html
    end
  end

  def serialize_trip
    trip_serialization(params)

    respond_to do |f|
      f.json { render json: @tripResponse }
    end
  end

  def plan
    @trip = Trip.find(params[:id])
    @trip_parts = @trip.trip_parts
    @satisfaction_survey = SatisfactionSurvey.new
    @user_services= {}

    unless params[:itinids].nil?
      @is_review = false
      @itineraries = Itinerary.where('id in (' + params[:itinids] + ')')
      @trip.itineraries.selected.each do |itin|
        itin.selected = false
        itin.save
      end

      #Mark these itineraries as selected
      @itineraries.each do |itinerary|

        if itinerary.service_is_bookable?
          user_service = UserService.where(service: itinerary.service, user_profile: @traveler.user_profile).first_or_initialize
          @user_services[itinerary.id] = user_service
        end

        #Update the booking status if it has changed
        if itinerary.is_booked?
          itinerary.update_booking_status
        end

        itinerary.selected = true
        itinerary.save
      end
    else
      @is_review = true
      @itineraries = @trip.itineraries.selected
    end

    #check if each trip part has a valid selected itinerary
    #if not, should show alert message
    @is_plan_valid = true
    @trip.trip_parts.each do |trip_part|
      @is_plan_valid = trip_part.itineraries.selected.valid.count == 1
      break if !@is_plan_valid
      service = trip_part.itineraries.selected.valid.first.service
      if service
        if trip_part.is_return_trip?
          @trip.return_provider_id = service.provider.id
        else
          @trip.outbound_provider_id = service.provider.id
        end
      end
    end

    if assisting?
      @assisting_agency = current_user.agency || nil
    else
      @assisting_agency = nil
    end

    # update trip is_planned status
    @trip.update_attributes(is_planned: @is_plan_valid == true)

    if @is_plan_valid
      # Just before render, save off the html on the trip, so that we can access it later for ratings.
      planned_trip_html = render_to_string partial: "selected_itineraries_details", locals: { trip: @trip, for_db: true }
      @trip.update_attributes(planned_trip_html: planned_trip_html, needs_feedback_prompt: true)
      @booking_proxy = UserServiceProxy.new()

      respond_to do |format|
        format.html # plan.html.erb
        format.json { render json: @trip_parts }
      end
    else
      @tripHash = JSON.parse(@trip.to_json)
      flash.now[:alert] = TranslationEngine.translate_text(:error_couldnt_plan)
    end
  end

  def show_printer_friendly
    @print_map = true
    @show_hidden = params[:show_hidden]
    @print = params[:print]
    @hide_timeout = true

    if session[:current_trip_id]
      session[:current_trip_id] = nil
    end

    @trip.selected_itineraries.each do |itin|
      itin.map_image = create_static_map(itin)
      puts itin.map_image
      itin.save
    end

    respond_to do |format|
      format.html {
        if @trip.nil?
          render :show_printer_friendly_failed
        else
          @hide_navbar = true
          render
        end
      }
      format.json { render json: @trip }
    end
  end

  def email
    email_address = params[:email][:email_addresses]
    comments = params[:email][:email_comments]

    notice_text = TranslationEngine.translate_text(:email_sent_to).sub('%{email_sent_to}', email_address.split(/[ ,]+/).to_sentence)
    begin
      UserMailer.user_trip_email([email_address], @trip, comments, @traveler).deliver
    rescue Net::SMTPSyntaxError
      notice_text = TranslationEngine.translate_text(:invalid_email)
    end

    respond_to do |format|
      format.html { redirect_to plan_user_trip_path(@trip.creator, @trip, itinids: params[:itinids], locale: I18n.locale),
        :notice => notice_text  }
      format.json { render json: @trip }
    end
  end

  def email_provider
    Rails.logger.info "Begin email"
    emails = []
    @trip = Trip.find(params[:id].to_i)
    from_email = user_signed_in? ? current_user.email : params[:email][:from]

    #IF this is a guest, save their email address
    unless user_signed_in?
      @trip.user.email = from_email
      @trip.user.save
    end

    #If the outbound trip has selected an itinerary with a service, mail it. Otherwise mail the return itinerary
    if @trip.outbound_part.selected_itinerary.service
      provider = @trip.outbound_part.selected_itinerary.service.provider
    else
      provider = @trip.return_part.selected_itinerary.service.provider
    end

    comments = params[:email][:comments]
    if params[:email][:copy_self] == '1'
      emails << from_email
    end
    subject = TranslationEngine.translate_text(:provider_trip_email_subject).blank? ? Oneclick::Application.config.name + ' Trip Request' : TranslationEngine.translate_text(:provider_trip_email_subject)
    UserMailer.provider_trip_email(emails, @trip, subject, from_email, comments).deliver
    notice_text = TranslationEngine.translate_text(:email_sent_to).sub('%{email_sent_to}', provider.name)
    respond_to do |format|
      format.html { redirect_to user_trip_url(@trip.creator, @trip, locale: I18n.locale), :notice => notice_text  }
      format.json { render json: @trip }
    end
  end

  def email_itinerary
    @itinerary = Itinerary.find(params[:itinerary].to_i)

    Rails.logger.info "Begin email"
    email_addresses = params[:email][:email_addresses].split(/[ ,]+/)
    Rails.logger.info email_addresses.inspect
    email_addresses << current_user.email if user_signed_in? && params[:email][:send_to_me]
    email_addresses << current_traveler.email if assisting? && params[:email][:send_to_traveler]
    Rails.logger.info email_addresses.inspect
    from_email = user_signed_in? ? current_user.email : params[:email][:from]
    subject = TranslationEngine.translate_text(:user_itinerary_email_subject).blank? ? Oneclick::Application.config.name + ' Trip Itinerary' : TranslationEngine.translate_text(:user_itinerary_email_subject)
    UserMailer.user_itinerary_email(email_addresses, @trip, @itinerary, subject, from_email,
      params[:email][:email_comments], @traveler).deliver
    notice_text = TranslationEngine.translate_text(:email_sent_to).sub('%{email_sent_to}', email_addresses.join(', '))
    respond_to do |format|
      format.html { redirect_to user_trip_url(@trip.creator, @trip, locale: I18n.locale), :notice => notice_text  }
      format.json { render json: @trip }
    end
  end

  def email_feedback
    @trip = Trip.find(params[:id])
    if @trip.user.email
      Rails.logger.info "Begin email"
      UserMailer.feedback_email(@trip).deliver
      notice_text = TranslationEngine.translate_text(:email_sent_to).sub('%{email_sent_to}', @trip.user.email)
    else
      Rails.logger.info "no email found"
      notice_text = TranslationEngine.translate_text(:no_email_found)
    end

    if current_user.agency
      respond_to do |format|
        format.html { redirect_to admin_agency_trips_path(current_user.agency), :notice => notice_text, locale: I18n.locale  }
        format.json { render json: @trip }
      end
    elsif current_user.provider
      respond_to do |format|
        format.html { redirect_to admin_provider_trips_path(current_user.provider), :notice => notice_text, locale: I18n.locale  }
        format.json { render json: @trip }
      end
    else
      respond_to do |format|
        format.html { redirect_to admin_trips_path, :notice => notice_text, locale: I18n.locale  }
        format.json { render json: @trip }
      end
    end
  end

  def email_itinerary2_values
    services = @trip.trip_parts.collect {|tp| tp.itineraries.valid.selected.collect{|i| i.service.name}}
    providers = @trip.trip_parts.collect {|tp| tp.itineraries.valid.selected.collect{|i| i.provider.name}}
    respond_to do |format|
      # format.html { redirect_to user_trip_url(@trip.creator, @trip), :notice => "An email was sent to #{email_addresses.join(', ')}."  }
      format.json { render json: @trip }
    end
  end

  def email2
  end

  # GET /trips/1
  # GET /trips/1.json
  def details
    respond_to do |format|
      format.html # details.html.erb
      format.json { render json: @trip }
    end
  end

  # User wants to repeat a trip
  def repeat
    # make sure we can find the trip we are supposed to be repeating and that it belongs to us.
    if @trip.nil?
      redirect_to(user_trips_url(locale: I18n.locale), :flash => { :alert => TranslationEngine.translate_text(:error_404) })
      return
    end

    # create a new trip_proxy from the current trip
    @trip_proxy = create_trip_proxy(@trip)
    # set the flag so we know what to do when the user submits the form
    @trip_proxy.mode = MODE_REPEAT

    # Set the travel time/date to the default
    travel_date = default_trip_time

    if mobile?
      @trip_proxy.outbound_trip_date = travel_date.strftime("%Y-%m-%d")
      @trip_proxy.outbound_trip_time = travel_date.in_time_zone.strftime("%H:%M")
    else
      @trip_proxy.outbound_trip_date = travel_date.strftime(TRIP_DATE_FORMAT_STRING)
      @trip_proxy.outbound_trip_time = travel_date.in_time_zone.strftime(TRIP_TIME_FORMAT_STRING)
    end

    if @trip_proxy.is_round_trip == "1"
      return_trip_time = travel_date + DEFAULT_RETURN_TRIP_DELAY_MINS.minutes
      if mobile?
        @trip_proxy.return_trip_date = return_trip_time.strftime("%Y-%m-%d")
        @trip_proxy.return_trip_time = return_trip_time.in_time_zone.strftime("%H:%M")
      else
        @trip_proxy.return_trip_date = return_trip_time.strftime(TRIP_DATE_FORMAT_STRING)
        @trip_proxy.return_trip_time = return_trip_time.in_time_zone.strftime(TRIP_TIME_FORMAT_STRING)
      end
    end

    # Create markers for the map control
    @markers = create_trip_proxy_markers(@trip_proxy, session[:is_multi_od]).to_json
    @places = create_place_markers(@traveler.places)

    setup_modes

    @is_repeat = true

    respond_to do |format|
      format.html { render :action => 'edit'}
    end
  end

  # User wants to edit a trip in the future
  def edit
    Rails.logger.info 'edit multi_od? ' + session[:is_multi_od].to_s
    # make sure we can find the trip we are supposed to be updating and that it belongs to us.
    # if @trip.nil?
    #   redirect_to(user_trips_url, :flash => { :alert => TranslationEngine.translate_text(:error_404) })
    #   return
    # end
    # make sure that the trip can be modified
    unless @trip.can_modify
      please_create = "Please <a href='%s'>start</a> a new trip." % new_user_trip_path(@traveler) # TODO I18N
      redirect_to(:back, :flash => { :alert => [@trip.cant_modify_reason, please_create].join(' ').html_safe })
      return
    end

    setup_modes

    @trip_proxy = create_trip_proxy(@trip, modes: session[:modes_desired])
    @trip_proxy.mode = MODE_EDIT

    # Set the trip proxy Id to the PK of the trip so we can update it
    @trip_proxy.id = @trip.id

    # Create markers for the map control
    @markers = create_trip_proxy_markers(@trip_proxy, session[:is_multi_od]).to_json
    @places = create_place_markers(@traveler.places)

    @is_repeat = false

    respond_to do |format|
      format.html
    end
  end

  def unset_traveler

    # set or update the traveler session key with the id of the traveler
    stop_assisting
    # set the @traveler variable
    get_traveler

    redirect_to root_path(locale: I18n.locale), :alert => TranslationEngine.translate_text(:assisting_turned_off)

  end

  # The user has elected to assist another user.
  def set_traveler

    # set or update the traveler session key with the id of the traveler
    set_traveler_id(params[:trip_proxy][:traveler])

    # set the @traveler variable
    get_traveler

    # show the new form
    redirect_to new_user_trip_path(@traveler)

  end

  # called when the user wants to delete a trip
  def destroy
    # make sure we can find the trip we are supposed to be removing and that it belongs to us.
    if @trip.nil?
      redirect_to(user_trips_url, :flash => { :alert => TranslationEngine.translate_text(:error_404) })
      return
    end
    # make sure that booked and future trip cannot be deleted
    if @trip.is_booked? and @trip.can_modify
      redirect_to(user_url, :flash => { :alert => TranslationEngine.translate_text(:error_404) })
      return
    end

    if @trip
      # remove any child objects
      @trip.clean
      @trip.destroy
      message = TranslationEngine.translate_text(:trip_was_successfully_removed)
    else
      render text: TranslationEngine.translate_text(:error_404), status: 404
      return
    end

    respond_to do |format|
      format.html { redirect_to(user_trips_path(@traveler), :flash => { :notice => message}) }
      format.json { head :no_content }
    end

  end

  # GET /trips/new
  # GET /trips/new.json
  def new
    session[:is_multi_od] = false
    session[:multi_od_trip_id] = nil
    session[:multi_od_trip_edited] = false
    @traveler.clear_stale_answers

    new_trip

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @trip_proxy }
    end
  end


  # updates a trip
  def update

    setup_modes

    # make sure we can find the trip we are supposed to be updating and that it belongs to us.
    if @trip.nil?
      redirect_to(user_trips_url, :flash => { :alert => TranslationEngine.translate_text(:error_404) })
      return
    end
    # make sure that the trip can be modified
    unless @trip.can_modify
      please_create = "Please <a href='%s'>start</a> a new trip." % new_user_trip_path(@traveler) # TODO I18N
      redirect_to(:back, :flash => { :alert => [@trip.cant_modify_reason, please_create].join(' ').html_safe })
      return
    end

    # Get the updated trip proxy from the form params
    @trip_proxy = create_trip_proxy_from_form_params(params[:trip_proxy])

    @trip_proxy.user_agent = request.user_agent
    @trip_proxy.ui_mode = @ui_mode

    session[:modes_desired] = @trip_proxy.modes_desired

    # TODO If trip_proxy isn't valid, should go back to form right now, before this.
    if @trip_proxy.valid?
      updated_trip = Trip.create_from_proxy(@trip_proxy, current_or_guest_user, @traveler)
    else
      Rails.logger.info "Not valid: #{@trip_proxy.ai}"
      Rails.logger.info "\nError render 1\n"
      flash.now[:notice] = TranslationEngine.translate_text(:correct_errors_to_create_a_trip)
      render action: "new"
      return
    end

    # save the id of the trip we are updating
    @trip_proxy.id = @trip.id

    # Create markers for the map control
    #@markers = create_trip_proxy_markers(@trip_proxy, session[:is_multi_od]).to_json
    #@places = create_place_markers(@traveler.places)

    # see if we can continue saving this trip
    if @trip_proxy.valid?

      # remove any child objects in the old trip
      @trip.clean
      @trip.save

      # Start updating the trip from the form-based one

      # update the associations
      @trip.trip_purpose = updated_trip.trip_purpose
      @trip.trip_purpose_raw = updated_trip.trip_purpose_raw
      @trip.desired_modes = updated_trip.desired_modes
      @trip.creator = @traveler
      @trip.agency = @traveler.agency

      updated_trip.trip_places.each do |tp|
        tp.trip = @trip
        @trip.trip_places << tp
      end
      updated_trip.trip_parts.each do |pt|
        pt.trip = @trip
        @trip.trip_parts << pt
      end
    end

    session[:multi_od_trip_id] = session[:multi_od_trip_id] || params[:multi_od_trip_id]
    if !session[:multi_od_trip_id].nil?
      session[:multi_od_trip_edited] = true
      @multi_od_trip = MultiOriginDestTrip.find(session[:multi_od_trip_id])
      @multi_od_trip.user = current_user
      @multi_od_trip.origin_places = params[:trip_proxy][:multi_origin_places]
      @multi_od_trip.dest_places = params[:trip_proxy][:multi_dest_places]
      @multi_od_trip.save
    end

    respond_to do |format|
      if updated_trip # only created if the form validated and there are no geocoding errors
        if @trip.save
          @trip.reload

          if session[:is_multi_od] == true
            @path = user_trip_multi_od_grid_path(@traveler, @trip, @multi_od_trip)
          else
            @path = user_trip_path(@traveler, @trip)
          end

          format.html { redirect_to @path }
          format.json { render json: @trip, status: :created, location: @trip }
        else
          Rails.logger.info "\nError render 2\n"
          Rails.logger.info "ERRORS: #{@trip.errors.ai}"
          Rails.logger.info "PLACES: #{@trip.trip_places.ai}"
          flash.now[:notice] = TranslationEngine.translate_text(:correct_errors_to_create_a_trip)
          format.html { render action: "new" }
          format.json { render json: @trip_proxy.errors, status: :unprocessable_entity }
        end
      else
        Rails.logger.info "\nError render 3\n"
        flash.now[:notice] = TranslationEngine.translate_text(:correct_errors_to_create_a_trip)
        format.html { render action: "new" }
      end
    end

  end

  def populate
    redirect_to user_trip_path(@traveler, @trip)
  end

  # POST /trips
  # POST /trips.json
  def create
    # inflate a trip proxy object from the form params
    Rails.logger.info 'create multi_od? ' + session[:is_multi_od].to_s
    if session[:is_multi_od] == true
      multi_od_trip = MultiOriginDestTrip.new(
        :user => current_user,
        :origin_places => params[:trip_proxy][:multi_origin_places],
        :dest_places => params[:trip_proxy][:multi_dest_places]
      )
      multi_od_trip.save
      session[:multi_od_trip_id] = multi_od_trip.id
    end


    @trip_proxy = create_trip_proxy_from_form_params(params[:trip_proxy])
    launch_trip_planning(@trip_proxy)

  end

  # GET
  def plan_a_trip

    session[:is_multi_od] = false
    session[:multi_od_trip_id] = nil
    session[:multi_od_trip_edited] = false

    session[:tabs_visited] = []

    params['mode'] = 2
    unless params["modes"].nil?
      params["modes"] = params["modes"].split(',')
      if params["modes"].length == 0
        params["modes"] = nil
      end
    end

    if params['return_arrive_depart'].nil?
      params['return_arrive_depart'] = true
    end

    purpose = TripPurpose.where(code: params["purpose"]).first || TripPurpose.first
    trip_purpose_raw = params["trip_purpose_raw"]

    params['trip_purpose_id'] = purpose.id if purpose
    params['trip_purpose_raw'] = trip_purpose_raw

    @trip_proxy = create_trip_proxy_from_form_params(params)

    @trip_proxy.is_round_trip = false
    if params['is_round_trip'] == '0' or params['is_round_trip'] == 'false'
      @trip_proxy.is_round_trip = false
    end

    @trip_proxy.traveler = @traveler
    @trip_proxy.user_agent = request.user_agent
    @trip_proxy.ui_mode = @ui_mode

    travel_date = default_trip_time
    if @trip_proxy.outbound_trip_date.nil?
      @trip_proxy.outbound_trip_date = (mobile? ? travel_date.strftime("%Y-%m-%d") : travel_date.strftime(TRIP_DATE_FORMAT_STRING))
    end
    if @trip_proxy.outbound_trip_time.nil?
      @trip_proxy.outbound_trip_time = (mobile? ? travel_date.strftime("%H:%M") : travel_date.strftime(TRIP_TIME_FORMAT_STRING))
    end

    # The default return trip time is set the the default trip time plus a configurable interval
    return_trip_time = travel_date + DEFAULT_RETURN_TRIP_DELAY_MINS.minutes
    if @trip_proxy.return_trip_date.nil?
      @trip_proxy.return_trip_date = (mobile? ? return_trip_time.strftime("%Y-%m-%d") : return_trip_time.strftime(TRIP_DATE_FORMAT_STRING))
    end
    if @trip_proxy.return_trip_time.nil?
      @trip_proxy.return_trip_time = (mobile? ? return_trip_time.strftime("%H:%M") : return_trip_time.strftime(TRIP_TIME_FORMAT_STRING))
    end

    # Create markers for the map control
    @markers = create_trip_proxy_markers(@trip_proxy, session[:is_multi_od]).to_json
    @places = create_place_markers(@traveler.places)

    if session[:first_login] == true
      @first_time = true
    else
      @first_time = false
    end
    session[:first_login] = nil

    if Oneclick::Application.config.allows_booking and not @traveler.can_book?
      @show_booking = true
      @booking_proxy = UserServiceProxy.new()
    end

    session[:modes_desired] = @trip_proxy.modes_desired
    setup_modes

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @trip_proxy }
    end
  end

  def skip
    @trip = Trip.find(session[:current_trip_id])
    @trip.trip_parts.each do |tp|
      tp.create_itineraries
    end
    @path = user_trip_path(@traveler, @trip)
    session[:current_trip_id] = nil

    respond_to do |format|
      format.html { redirect_to @path }
    end
  end

  # Called when the user displays an itinerary details in the modal popup
  def itinerary
    @itinerary = @trip.itineraries.valid.find(params[:itin])
    @legs = @itinerary.get_legs
    if @itinerary.is_mappable
      @markers = create_itinerary_markers(@itinerary).to_json
      @polylines = create_itinerary_polylines(@legs).to_json
      @sidewalk_feedback_markers = create_itinerary_sidewalk_feedback_markers(@legs).to_json
    end

    #Rails.logger.debug @itinerary.inspect
    #Rails.logger.debug @markers.inspect
    #Rails.logger.debug @polylines.inspect

    @itinerary = ItineraryDecorator.decorate(@itinerary)
    respond_to do |format|
      format.js
    end

  end

  def itinerary_map
    @trip = Trip.find(params[:id])
    @itinerary = @trip.itineraries.valid.find(params[:itin])

    if @itinerary.is_mappable
      @legs = @itinerary.get_legs
      @markers = create_itinerary_markers(@itinerary).to_json
      @polylines = create_itinerary_polylines(@legs).to_json
      @sidewalk_feedback_markers = create_itinerary_sidewalk_feedback_markers(@legs).to_json
    end

    @itinerary = ItineraryDecorator.decorate(@itinerary)
    respond_to do |format|
      format.html
    end
  end

  # called when the user wants to hide an option. Invoked via
  # an ajax call
  def hide
    itinerary = @trip.itineraries.valid.find(params[:itinerary])
    if itinerary.nil?
      render text: TranslationEngine.translate_text(:unable_to_remove_itinerary), status: 500
      return
    end

    itinerary.hidden = true

    respond_to do |format|
      if itinerary.save
        @trip.reload
        # format.js # hide.js.haml
        # TOOD For now, don't do ajax
        format.html { redirect_to user_trip_path(@traveler, @trip) }
      else
        # TODO for now, no ajax
        # render text: TranslationEngine.translate_text(:unable_to_remove_itinerary), status: 500
        format.html { redirect_to(user_trip_path(@traveler, @trip), :flash => { error: TranslationEngine.translate_text(:unable_to_remove_itinerary)}) }
      end
    end
  end

  # Unhides all the hidden itineraries for a trip
  def unhide_all
    @trip.itineraries.valid.hidden.each do |i|
      i.hidden = false
      i.save
    end
    redirect_to user_trip_path(@traveler, @trip)
  end

  def unselect_all
    @trip.unselect_all

  end

  def select
    itinerary = Itinerary.find(params[:itin])
    itinerary.update_attribute :selected, true
    respond_to do |format|
      format.html { redirect_to(user_trip_path(@traveler, @trip)) }
      format.json { head :no_content }
    end
  end

  def book

    respond_to do |format|
      format.json { render json: @trip.book }
    end

  end

  def new_rating_from_email
    @trip = Trip.find(params[:id])
    unless ((@trip.md5_hash.eql? params[:hash]) || (authorize! :create, @trip.ratings.build(rateable: @trip)))
      flash[:notice] = TranslationEngine.translate_text(:http_404_not_found)
      redirect_to :root
    end

    taken = true.to_s.eql? params[:taken] # convert to a boolean for future use (ruby isn't falsy enough for me here)
    @trip.taken = taken
    @trip.save

    unless taken
      render 'ratings/untaken_trip'
    else
      @ratings_proxy = RatingsProxy.new(@trip, @trip.user) # rateable must be a trip here.  Guarded by the initial check (md5 hash)
      render 'ratings/new_from_email'
    end
  end

  def cancel
    trip = Trip.find(params[:id].to_i)
    result = trip.cancel

    if result
      message = TranslationEngine.translate_text(:cancel_booking_success)
    else
      message = TranslationEngine.translate_text(:cancel_booking_failure)
    end

    respond_to do |format|
      format.html { redirect_to(user_trips_path(@traveler), :flash => { :notice => message}) }
      format.json { head :no_content }
    end
  end

protected
  def new_trip
    session[:tabs_visited] = []
    @trip_proxy = TripProxy.new(modes: session[:modes_desired], outbound_arrive_depart: false, return_arrive_depart: true) # default outbound trips to arrive-by, return trips to depart-at.
    @trip_proxy.traveler = @traveler

    # set the flag so we know what to do when the user submits the form
    travel_date = default_trip_time

    if mobile?
      @trip_proxy.outbound_trip_date = travel_date.strftime("%Y-%m-%d")
      @trip_proxy.outbound_trip_time = travel_date.strftime("%H:%M")
    else
      @trip_proxy.outbound_trip_date = travel_date.strftime(TRIP_DATE_FORMAT_STRING)
      @trip_proxy.outbound_trip_time = travel_date.strftime(TRIP_TIME_FORMAT_STRING)
    end

    # Set the trip purpose to its default
    first_purpose = TripPurpose.first
    @trip_proxy.trip_purpose_id = first_purpose.id if first_purpose

    @trip_proxy.user_agent = request.user_agent
    @trip_proxy.ui_mode = @ui_mode

    # default to a round trip. The default return trip time is set the the default trip time plus
    # a configurable interval
    return_trip_time = travel_date + DEFAULT_RETURN_TRIP_DELAY_MINS.minutes
    @trip_proxy.is_round_trip = false

    if mobile?
      @trip_proxy.return_trip_date = return_trip_time.strftime("%Y-%m-%d")
      @trip_proxy.return_trip_time = return_trip_time.strftime("%H:%M")
    else
      @trip_proxy.return_trip_date = return_trip_time.strftime(TRIP_DATE_FORMAT_STRING)
      @trip_proxy.return_trip_time = return_trip_time.strftime(TRIP_TIME_FORMAT_STRING)
    end

    # Create markers for the map control
    @markers = create_trip_proxy_markers(@trip_proxy, session[:is_multi_od]).to_json
    @places = create_place_markers(@traveler.places)

    if session[:first_login] == true
      @first_time = true
    else
      @first_time = false
    end
    session[:first_login] = nil


    if Oneclick::Application.config.allows_booking and not @traveler.can_book?
      @show_booking = true
      @booking_proxy = UserServiceProxy.new()
    end
    setup_modes
  end

 def launch_trip_planning(trip_proxy)
    trip_proxy.user_agent = request.user_agent
    trip_proxy.ui_mode = @ui_mode

    session[:modes_desired] = trip_proxy.modes_desired

    setup_modes
    if Oneclick::Application.config.allows_booking and not @traveler.can_book?
      @show_booking = true
      @booking_proxy = UserServiceProxy.new()
    end

    unless trip_proxy.valid?
      Rails.logger.info "Not valid: #{@trip_proxy.ai}"
      Rails.logger.info "\nError render 1\n"
      flash.now[:alert] = TranslationEngine.translate_text(:correct_errors_to_create_a_trip)
      render action: "new"
      return
    end

    respond_to do |format|
      Rails.logger.info trip_proxy.to_json
      @trip = Trip.create_from_proxy(trip_proxy, current_or_guest_user, @traveler)
      Rails.logger.info @trip.trip_places.first.name
      if @trip
        if @trip.errors.empty? && @trip.save
          @trip.reload
          Rails.logger.info 'trip_planning multi_od? ' + session[:is_multi_od].to_s

          if session[:is_multi_od] == true
            session[:multi_od_trip_id] = session[:multi_od_trip_id] || params[:multi_od_trip_id]
            @multi_od_trip = MultiOriginDestTrip.find(session[:multi_od_trip_id])
            @path = user_trip_multi_od_grid_path(@traveler, @trip, @multi_od_trip)
          else

            # changed to async loading
            @trip.remove_itineraries
            @path = populate_user_trip_path(@traveler, @trip, {asynch: 1}, locale: I18n.locale )
          end

          format.html { redirect_to @path }
          format.json { render json: @trip, status: :created, location: @trip }
        else
          # TODO Will this get handled correctly?

          Rails.logger.info "\nError render 2\n"
          Rails.logger.info "ERRORS: #{@trip.errors.ai}"
          Rails.logger.info "PLACES: #{@trip.trip_places.ai}"
          Rails.logger.info "PLACE ERRORS: #{@trip.trip_places.collect{|tp| tp.errors}}"
          trip_proxy.errors = @trip.errors
          flash.now[:alert] = TranslationEngine.translate_text(:correct_errors_to_create_a_trip)
          format.html { render action: "new" }
          format.json { render json: trip_proxy.errors, status: :unprocessable_entity }
        end
      else
        # TODO Will this get handled correctly?
        Rails.logger.info "\nError render 3\n"
        Rails.logger.info "ERRORS: #{@trip.errors.ai}"
        Rails.logger.info "PLACES: #{@trip.trip_places.ai}"
        flash.now[:alert] = TranslationEngine.translate_text(:correct_errors_to_create_a_trip)
        format.html { render action: "new" }
      end
    end
  end

  # Set the default travel time/date to x mins from now
  #TODO: Make this an ENV
  def default_trip_time
    return (Time.now + DEFAULT_OUTBOUND_TRIP_AHEAD_MINS.minutes).in_time_zone.next_interval(DEFAULT_TRIP_TIME_AHEAD_MINS.minutes)
  end

  # Safely set the @trip variable taking into account trip ownership
  def get_trip
    # limit trips to trips accessible by the user unless an admin
    Rails.logger.info "get_trip, traveler is #{@traveler}"
    if can? :manage, :all
      Rails.logger.info "get_trip, traveler is admin"
      begin
        @trip = Trip.find(params[:id])
      rescue => ex
        Rails.logger.info "get_trip: #{ex.message}"
        @trip = nil
      end
    else
      begin
        @trip = @traveler.trips.find(params[:id])
        Rails.logger.info "Normal user found trip: #{@trip}"
      rescue => ex
        Rails.logger.info "get_trip: #{ex.message}"
        @trip = nil
      end
    end
    Rails.logger.info "get_trip, returning, @trip is #{@trip}"
  end

  def trip_serialization(params)
    @trip = Trip.find(params[:id].to_i)
    params[:asynch] = (params[:asynch] || true).to_bool
    params[:regen] = (params[:regen] || false).to_bool
    if params[:regen] or session[:multi_od_trip_edited] == true
      @trip.remove_itineraries
      @trip.create_itineraries
    end
    #@tripResponse = TripSerializer.new(@trip, params) #sync-dislay: response to review page to display all itineraries at one time
    @tripResponse = TripSerializer.new(@trip, params) #async-dislay: response to review page to incrementally display itineraries

    # TODO This seems incredibly hacky to go to json and back for this, but...
    @tripResponseHash = JSON.parse(@tripResponse.to_json)
    if @tripResponseHash['status'] == 0
      flash.now[:alert] = TranslationEngine.translate_text(:error_couldnt_plan)
    end
  end

  # Create an array of map markers suitable for the Leaflet plugin. If the trip proxy is from an existing trip we will
  # have start and stop markers
  def create_markers(trip_proxy)
    markers = []
    if trip_proxy.from_place_selected
      place = get_preselected_place(trip_proxy.from_place_selected_type, trip_proxy.from_place_selected, true)
    else
      place = {:name => trip_proxy.from_place, :lat => trip_proxy.from_lat, :lon => trip_proxy.from_lon, :formatted_address => trip_proxy.from_raw_address}
    end
    markers << get_addr_marker(place, 'start', 'startIcon')

    if trip_proxy.to_place_selected
      place = get_preselected_place(trip_proxy.to_place_selected_type, trip_proxy.to_place_selected, false)
    else
      place = {:name => trip_proxy.to_place, :lat => trip_proxy.to_lat, :lon => trip_proxy.to_lon, :formatted_address => trip_proxy.to_raw_address}
    end

    markers << get_addr_marker(place, 'stop', 'stopIcon')
    return markers.to_json
  end

  def create_place_markers(places)
    markers = []
    places.each_with_index do |place, index|
      markers << get_map_marker(place, place.id, 'startIcon')
    end
    return markers
  end

private
  # creates a trip_proxy object from form parameters
  def create_trip_proxy_from_form_params(trip_proxy_params)
    trip_proxy = TripProxy.new(trip_proxy_params)
    trip_proxy.traveler = @traveler

    if trip_proxy.modes.nil?
      modes = ['mode_paratransit', 'mode_taxi', 'mode_transit']
      trip_proxy.desired_modes = Mode.where(code: modes)
    end

    Rails.logger.debug trip_proxy.inspect
    return trip_proxy
  end

  def create_trip_proxy(trip, attr = {})
    trip_proxy = TripProxy.create_from_trip(trip, attr)
    if !session[:multi_od_trip_id].nil?
      multi_od_trip = MultiOriginDestTrip.find(session[:multi_od_trip_id])
      trip_proxy.multi_origin_places = multi_od_trip.origin_places
      trip_proxy.multi_dest_places = multi_od_trip.dest_places
    end

    trip_proxy
  end

  def setup_modes
    Rails.logger.info "TripsController#setup_modes"
    mode_hash = Mode.setup_modes(session[:modes_desired])
    @modes = mode_hash[:modes]
    @transit_modes = mode_hash[:transit_modes]
    @selected_modes = mode_hash[:selected_modes]
  end

  def get_trip_purposes

    @trip_purposes = []
    TripPurpose.all.each do |trip_purpose|
      new_trip_purpose = []
      new_trip_purpose[0] = TranslationEngine.translate_text(trip_purpose.name)
      new_trip_purpose[1] = trip_purpose.id
      @trip_purposes.push(new_trip_purpose)
    end

  end

  #Deprecated, but not removed because it is currently used by the FindMyRide UI
  def get_ecolane_trip_purposes
    # GENERIC_BOOKING
    @trip_purpose_raw = nil
    return @trip_purposes_raw
    if @traveler.user_profile.user_services.count > 0
      eh = EcolaneHelpers.new
      @trip_purposes_raw = eh.get_trip_purposes_from_traveler(@traveler)
    else
      @trip_purposes_raw = nil
    end

  end

  def detect_ui_mode
    case request.user_agent
    when /iPad/i
      @ui_mode = :tablet
    when /phone/i, /mobile/i
      @ui_mode = :phone
    when /Android/i
      @ui_mode = :tablet
    else
      @ui_mode = :desktop
    end
  end

end
