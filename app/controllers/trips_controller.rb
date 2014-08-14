class TripsController < PlaceSearchingController
  # set the @trip variable before any actions are invoked
  before_filter :get_trip, :only => [:show, :email, :email_itinerary, :details, :repeat, :edit,
    :destroy, :update, :itinerary, :hide, :unhide_all, :select, :email_itinerary2_values, :email2,
    :show_printer_friendly, :example, :plan, :populate, :book]
  load_and_authorize_resource only: [:new, :create, :show, :index, :update, :edit]

  def index

    @trips = User.find(params[:user_id]).trips
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @trips }
    end

  end

  def show_old
    @show_hidden = params[:show_hidden]

    if session[:current_trip_id]
      session[:current_trip_id] = nil
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @trip }
    end
  end

  def show
    @trip = Trip.find(params[:id].to_i)
    params[:asynch] = (params[:asynch] || true).to_bool
    params[:regen] = (params[:regen] || false).to_bool
    if params[:regen]
      @trip.remove_itineraries
      @trip.create_itineraries
    end
    #@tripResponse = TripSerializer.new(@trip, params) #sync-dislay: response to review page to display all itineraries at one time 
    @tripResponse = TripSerializer.new(@trip, params) #async-dislay: response to review page to incrementally display itineraries

    # TODO This seems incredibly hacky to go to json and back for this, but...
    @tripResponseHash = JSON.parse(@tripResponse.to_json)
    if @tripResponseHash['status'] == 0
      Honeybadger.notify(
        :error_class   => "Trip serialization failure for review page",
        :error_message => @tripResponseHash['status_text'],
        :parameters    => @tripResponseHash
      )
      flash.now[:alert] = t(:error_couldnt_plan)
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @tripResponse }
    end
  end

  def plan
    @itineraries = Itinerary.where('id in (' + params[:itinids] + ')')
    @trip = Trip.find(params[:id])
    @trip_parts = @trip.trip_parts

    @trip.itineraries.selected.each do |itin|
      itin.selected = false
      itin.save
    end

    #Mark these itineraries as selected
    @itineraries.each do |itinerary|
      itinerary.selected = true
      itinerary.save
    end

    #check if each trip part has a valid selected itinerary
    #if not, should show alert message
    @is_plan_valid = true
    @trip.trip_parts.each do |trip_part|  
      @is_plan_valid = trip_part.itineraries.selected.valid.count == 1
      break if !@is_plan_valid  
    end

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
      Honeybadger.notify(
        :error_class   => "Some selected itineraries not available for Plan page",
        :error_message => "Supposedly each trip part should have one and only valid selected itinerary, however, this is not the case. Check parameters about trip data.",
        :parameters    => @tripHash
      )
      flash.now[:alert] = t(:error_couldnt_plan)
    end
  end

  def show_printer_friendly
    @show_hidden = params[:show_hidden]
    @print = params[:print]
    @hide_timeout = true

    if session[:current_trip_id]
      session[:current_trip_id] = nil
    end

    respond_to do |format|
      format.html {
        render :show_printer_friendly_failed if @trip.nil?
      }
      format.json { render json: @trip }
    end
  end

  def email
    Rails.logger.info "Begin email"
    email_addresses = params[:email][:email_addresses].split(/[ ,]+/)
    if user_signed_in? and params[:email][:send_email_to]
      params[:email][:send_email_to].each do |email|
        unless email == ""
          email_addresses << email
        end
      end
    end

    email_addresses = email_addresses.uniq
    Rails.logger.info email_addresses.inspect
    from_email = user_signed_in? ? current_user.email : params[:email][:from]
    if from_email == ""
      from_email = Oneclick::Application.config.name
    end
    subject = Oneclick::Application.config.name + ' Trip Itinerary'
    UserMailer.user_trip_email(email_addresses, @trip, subject, from_email,
      params[:email][:email_comments]).deliver
    notice_text = t(:email_sent_to).sub('%{email_sent_to}', email_addresses.to_sentence)
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
    subject = Oneclick::Application.config.name + ' Trip Request'
    UserMailer.provider_trip_email(emails, @trip, subject, from_email, comments).deliver
    notice_text = t(:email_sent_to).sub('%{email_sent_to}', provider.name)
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
    subject = Oneclick::Application.config.name + ' Trip Itinerary'
    UserMailer.user_itinerary_email(email_addresses, @trip, @itinerary, subject, from_email,
      params[:email][:email_comments]).deliver
    notice_text = t(:email_sent_to).sub('%{email_sent_to}', email_addresses.join(', '))
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
      notice_text = t(:email_sent_to).sub('%{email_sent_to}', @trip.user.email)
    else
      Rails.logger.info "no email found"
      notice_text = t(:no_email_found)
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
    # @itinerary = Itinerary.find(params[:itinerary].to_i)

    # Rails.logger.info "Begin email"
    # email_addresses = params[:email][:email_addresses].split(/[ ,]+/)
    # Rails.logger.info email_addresses.inspect
    # email_addresses << current_user.email if user_signed_in? && params[:email][:send_to_me]
    # email_addresses << current_traveler.email if assisting? && params[:email][:send_to_traveler]
    # Rails.logger.info email_addresses.inspect
    # from_email = user_signed_in? ? current_user.email : params[:email][:from]
    # UserMailer.user_itinerary_email(email_addresses, @trip, @itinerary, "ARC OneClick Trip Itinerary", from_email).deliver
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
      redirect_to(user_trips_url(locale: I18n.locale), :flash => { :alert => t(:error_404) })
      return
    end

    # create a new trip_proxy from the current trip
    @trip_proxy = create_trip_proxy(@trip)
    # set the flag so we know what to do when the user submits the form
    @trip_proxy.mode = MODE_REPEAT

    # Set the travel time/date to the default
    travel_date = default_trip_time

    @trip_proxy.outbound_trip_date = travel_date.strftime(TRIP_DATE_FORMAT_STRING)
    @trip_proxy.outbound_trip_time = travel_date.in_time_zone.strftime(TRIP_TIME_FORMAT_STRING)

    if @trip_proxy.is_round_trip == "1"
      return_trip_time = travel_date + DEFAULT_RETURN_TRIP_DELAY_MINS.minutes
      @trip_proxy.return_trip_time = return_trip_time.in_time_zone.strftime(TRIP_TIME_FORMAT_STRING)
    end

    # Create markers for the map control
    @markers = create_trip_proxy_markers(@trip_proxy).to_json
    @places = create_place_markers(@traveler.places)

    setup_modes

    respond_to do |format|
      format.html { render :action => 'edit'}
    end
  end

  # User wants to edit a trip in the future
  def edit
    # make sure we can find the trip we are supposed to be updating and that it belongs to us.
    # if @trip.nil?
    #   redirect_to(user_trips_url, :flash => { :alert => t(:error_404) })
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
    @markers = create_trip_proxy_markers(@trip_proxy).to_json
    @places = create_place_markers(@traveler.places)

    respond_to do |format|
      format.html
    end
  end

  def unset_traveler

    # set or update the traveler session key with the id of the traveler
    stop_assisting
    # set the @traveler variable
    get_traveler

    redirect_to root_path(locale: I18n.locale), :alert => t(:assisting_turned_off)

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
      redirect_to(user_trips_url, :flash => { :alert => t(:error_404) })
      return
    end
    # make sure that the trip can be modified
    unless @trip.can_modify
      redirect_to(user_url, :flash => { :alert => t(:error_404) })
      return
    end

    if @trip
      # remove any child objects
      @trip.clean
      @trip.destroy
      message = t(:trip_was_successfully_removed)
    else
      render text: t(:error_404), status: 404
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
    session[:tabs_visited] = []
    @trip_proxy = TripProxy.new(modes: session[:modes_desired], outbound_arrive_depart: false, return_arrive_depart: true) # default outbound trips to arrive-by, return trips to depart-at.
    @trip_proxy.traveler = @traveler

    # set the flag so we know what to do when the user submits the form
    @trip_proxy.mode = MODE_NEW

    # Set the travel time/date to the default
    travel_date = default_trip_time

    @trip_proxy.outbound_trip_date = travel_date.strftime(TRIP_DATE_FORMAT_STRING)
    @trip_proxy.outbound_trip_time = travel_date.strftime(TRIP_TIME_FORMAT_STRING)

    # Set the trip purpose to its default
    @trip_proxy.trip_purpose_id = TripPurpose.all.first.id

    # default to a round trip. The default return trip time is set the the default trip time plus
    # a configurable interval
    return_trip_time = travel_date + DEFAULT_RETURN_TRIP_DELAY_MINS.minutes
    @trip_proxy.is_round_trip = "1"
    @trip_proxy.return_trip_time = return_trip_time.strftime(TRIP_TIME_FORMAT_STRING)

    # Create markers for the map control
    @markers = create_trip_proxy_markers(@trip_proxy).to_json
    @places = create_place_markers(@traveler.places)

    if session[:first_login] == true
      session[:first_login] = nil
      @show_booking = true
      @booking_proxy = UserServiceProxy.new()
    end

    setup_modes

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
      redirect_to(user_trips_url, :flash => { :alert => t(:error_404) })
      return
    end
    # make sure that the trip can be modified
    unless @trip.can_modify
      please_create = "Please <a href='%s'>start</a> a new trip." % new_user_trip_path(@traveler) # TODO I18N
      redirect_to(:back, :flash => { :alert => [@trip.cant_modify_reason, please_create].join(' ').html_safe })
      return
    end

    # Get the updated trip proxy from the form params
    @trip_proxy = create_trip_proxy_from_form_params

    session[:modes_desired] = @trip_proxy.modes_desired

    # TODO If trip_proxy isn't valid, should go back to form right now, before this.
    if @trip_proxy.valid?
      updated_trip = Trip.create_from_proxy(@trip_proxy, current_or_guest_user, @traveler)
    else
      Rails.logger.info "Not valid: #{@trip_proxy.ai}"
      Rails.logger.info "\nError render 1\n"
      flash.now[:notice] = t(:correct_errors_to_create_a_trip)
      render action: "new"
      return
    end

    # save the id of the trip we are updating
    @trip_proxy.id = @trip.id

    # Create markers for the map control
    @markers = create_trip_proxy_markers(@trip_proxy).to_json
    @places = create_place_markers(@traveler.places)

    # see if we can continue saving this trip
    if @trip_proxy.valid?

      # remove any child objects in the old trip
      @trip.clean
      @trip.save

      # Start updating the trip from the form-based one

      # update the associations
      @trip.trip_purpose = updated_trip.trip_purpose
      @trip.desired_modes = updated_trip.desired_modes
      @trip.creator = @traveler
      updated_trip.trip_places.each do |tp|
        tp.trip = @trip
        @trip.trip_places << tp
      end
      updated_trip.trip_parts.each do |pt|
        pt.trip = @trip
        @trip.trip_parts << pt
      end
    end

    respond_to do |format|
      if updated_trip # only created if the form validated and there are no geocoding errors
        if @trip.save
          @trip.reload

          if !@trip.eligibility_dependent?
            @path = user_trip_path_for_ui_mode(@traveler, @trip)
          else
            session[:current_trip_id] = @trip.id
            @path = new_user_trip_characteristic_path_for_ui_mode(@traveler, @trip)
          end
          format.html { redirect_to @path }
          format.json { render json: @trip, status: :created, location: @trip }
        else
          Rails.logger.info "\nError render 2\n"
          Rails.logger.info "ERRORS: #{@trip.errors.ai}"
          Rails.logger.info "PLACES: #{@trip.trip_places.ai}"
          flash.now[:notice] = t(:correct_errors_to_create_a_trip)          
          format.html { render action: "new" }
          format.json { render json: @trip_proxy.errors, status: :unprocessable_entity }
        end
      else
        Rails.logger.info "\nError render 3\n"
        flash.now[:notice] = t(:correct_errors_to_create_a_trip)          
        format.html { render action: "new" }
      end
    end

  end

  def populate
    redirect_to user_trip_path_for_ui_mode(@traveler, @trip)
  end

  # POST /trips
  # POST /trips.json
  def create

    # inflate a trip proxy object from the form params
    @trip_proxy = create_trip_proxy_from_form_params

    session[:modes_desired] = @trip_proxy.modes_desired

    setup_modes

    if @trip_proxy.valid?
      @trip = Trip.create_from_proxy(@trip_proxy, current_or_guest_user, @traveler)
    else
      Rails.logger.info "Not valid: #{@trip_proxy.ai}"
      Rails.logger.info "\nError render 1\n"
      flash.now[:alert] = t(:correct_errors_to_create_a_trip)
      render action: "new"
      return
    end

    # Create markers for the map control
    @markers = create_trip_proxy_markers(@trip_proxy).to_json
    @places = create_place_markers(@traveler.places)

    respond_to do |format|
      if @trip
        if @trip.errors.empty? && @trip.save
          @trip.reload
          if !@trip.eligibility_dependent?
            @trip.create_itineraries
            @path = user_trip_path_for_ui_mode(@traveler, @trip)
          else
            session[:current_trip_id] = @trip.id
            @path = new_user_trip_characteristic_path_for_ui_mode(@traveler, @trip)
          end
          format.html { redirect_to @path }
          format.json { render json: @trip, status: :created, location: @trip }
        else
          # TODO Will this get handled correctly?
          Rails.logger.info "\nError render 2\n"
          Rails.logger.info "ERRORS: #{@trip.errors.ai}"
          Rails.logger.info "PLACES: #{@trip.trip_places.ai}"
          Rails.logger.info "PLACE ERRORS: #{@trip.trip_places.collect{|tp| tp.errors}}"
          @trip_proxy.errors = @trip.errors
          flash.now[:alert] = t(:correct_errors_to_create_a_trip)
          format.html { render action: "new" }
          format.json { render json: @trip_proxy.errors, status: :unprocessable_entity }
        end
      else
        # TODO Will this get handled correctly?
        Rails.logger.info "\nError render 3\n"
        Rails.logger.info "ERRORS: #{@trip.errors.ai}"
        Rails.logger.info "PLACES: #{@trip.trip_places.ai}"
        flash.now[:alert] = t(:correct_errors_to_create_a_trip)
        format.html { render action: "new" }
      end
    end
  end

  def skip
    @trip = Trip.find(session[:current_trip_id])
    @trip.trip_parts.each do |tp|
      tp.create_itineraries
    end
    @path = user_trip_path_for_ui_mode(@traveler, @trip)
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
    end

    #Rails.logger.debug @itinerary.inspect
    #Rails.logger.debug @markers.inspect
    #Rails.logger.debug @polylines.inspect

    @itinerary = ItineraryDecorator.decorate(@itinerary)
    respond_to do |format|
      format.js
    end

  end

  # called when the user wants to hide an option. Invoked via
  # an ajax call
  def hide
    itinerary = @trip.itineraries.valid.find(params[:itinerary])
    if itinerary.nil?
      render text: t(:unable_to_remove_itinerary), status: 500
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
        # render text: t(:unable_to_remove_itinerary), status: 500
        format.html { redirect_to(user_trip_path(@traveler, @trip), :flash => { error: t(:unable_to_remove_itinerary)}) }
      end
    end
  end

  # Unhides all the hidden itineraries for a trip
  def unhide_all
    @trip.itineraries.valid.hidden.each do |i|
      i.hidden = false
      i.save
    end
    redirect_to user_trip_path_for_ui_mode(@traveler, @trip)
  end

  def unselect_all
    @trip.itineraries.selected.each do |i|
      i.update_attribute :selected, false
    end
  end

  def select
    itinerary = Itinerary.find(params[:itin])
    itinerary.update_attribute :selected, true
    respond_to do |format|
      format.html { redirect_to(user_trip_path_for_ui_mode(@traveler, @trip)) }
      format.json { head :no_content }
    end
  end

  def book
    @itinerary = Itinerary.find(params[:itin].to_i )
    eh = EcolaneHelpers.new

    outbound_part = @itinerary.trip_part
    contact_number = ""
    if outbound_part.is_bookable?

      outbound_itinerary = @itinerary
      outbound_result, outbound_message = eh.book_itinerary(@itinerary)
      contact_number = outbound_itinerary.service.phone || ""
      unless outbound_result
        @trip.debug_info = @trip.debug_info.to_s + "[Outbound Booking Error: " + outbound_message.to_s + "]"
        @trip.save
      end
    else
      outbound_result = 'none'
      outbound_message = 'none'
    end

    return_part = @itinerary.trip_part.get_return_part
    if return_part and return_part.is_bookable?
      if contact_number.empty?
        return_itinerary = return_part.selected_itinerary
        contact_number = return_itinerary.service.phone || ""
      end
      return_result, return_message = eh.book_itinerary(return_part.selected_itinerary)
      unless return_result
        @trip.debug_info = @trip.debug_info.to_s + "[Return Booking Error: " + return_message.to_s + "]"
        @trip.save
      end
    else
      return_result = 'none'
      return_message = 'none'
    end

    respond_to do |format|
      format.json { render json: [outbound_result.to_s, outbound_message, return_result.to_s, return_message, contact_number] }
    end
  end

  def new_rating_from_email
    @trip = Trip.find(params[:id])
    unless ((@trip.md5_hash.eql? params[:hash]) || (authorize! :create, @trip.ratings.build(rateable: @trip)))
      flash[:notice] = t(:http_404_not_found)
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
protected

  
  # Set the default travel time/date to x mins from now
  def default_trip_time
    return Time.now.in_time_zone.next_interval(DEFAULT_TRIP_TIME_AHEAD_MINS.minutes)    
  end
  
  # Safely set the @trip variable taking into account trip ownership
  def get_trip
    # limit trips to trips accessible by the user unless an admin
    Rails.logger.info "get_trip, traveler is #{@traveler}"
    if @traveler.has_role? :admin
      Rails.logger.info "get_trip, traveler is admin"
      @trip = Trip.find(params[:id])
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
  def create_trip_proxy_from_form_params

    trip_proxy = TripProxy.new(params[:trip_proxy])
    trip_proxy.traveler = @traveler

    Rails.logger.debug trip_proxy.inspect
    return trip_proxy
  end

  def create_trip_proxy(trip, attr = {})
    TripProxy.create_from_trip(trip, attr)
  end

  def setup_modes
    mode_hash = Mode.setup_modes(session[:modes_desired])
    @modes = mode_hash[:modes]
    @transit_modes = mode_hash[:transit_modes]
    @selected_modes = mode_hash[:selected_modes]
  end

end
