module Kiosk
  class TripsController < ::TripsController
    include Behavior

    def show
      if params[:back]
        session[:current_trip_id] = @trip.id
        redirect_to new_user_characteristic_path_for_ui_mode(@traveler, inline: 1)
        return
      end

      super
    end

    def itinerary_print
      @itinerary = Itinerary.find(params[:id])
      @legs = @itinerary.get_legs
      @itinerary = ItineraryDecorator.decorate(@itinerary)
      @hide_timeout = true
    end

  # POST /trips
  # POST /trips.json
  def create

    # inflate a trip proxy object from the form params
    @trip_proxy = create_trip_proxy_from_form_params

    session[:modes_desired] = @trip_proxy.modes

    setup_modes

    # TODO If trip_proxy isn't valid, should go back to form right now, before this.
    if @trip_proxy.valid?
      @trip = Trip.create_from_proxy(@trip_proxy, current_or_guest_user, @traveler)
    else
      Rails.logger.info "Not valid: #{@trip_proxy.ai}"
      Rails.logger.info "\nError render 1\n"
      flash[:notice] = t(:correct_errors_to_create_a_trip)
      render action: "new"
      return
    end

    # Create markers for the map control
    @markers = create_trip_proxy_markers(@trip_proxy).to_json
    @places = create_place_markers(@traveler.places)

    respond_to do |format|
      if @trip
        if @trip.save
          @trip.reload
          if !@trip.eligibility_dependent? || (@traveler.user_profile.has_characteristics? and user_signed_in?)
            @trip.create_itineraries
            @path = user_trip_path_for_ui_mode(@traveler, @trip)
          else
            session[:current_trip_id] = @trip.id
            @path = new_user_characteristic_path_for_ui_mode(@traveler, inline: 1)
          end
          format.html { redirect_to @path }
          format.json { render json: @trip, status: :created, location: @trip }
        else
          # TODO Will this get handled correctly?
          Rails.logger.info "\nError render 2\n"
          format.html { render action: "new", flash[:alert] => t(:correct_errors_to_create_a_trip) }
          format.json { render json: @trip_proxy.errors, status: :unprocessable_entity }
        end
      else
        # TODO Will this get handled correctly?
        Rails.logger.info "\nError render 3\n"
        format.html { render action: "new", flash[:alert] => t(:correct_errors_to_create_a_trip) }
      end
    end
  end


  protected

    def back_url
      if params[:action] == 'show'
        url_for(back: true)
      end
    end
  end
end
