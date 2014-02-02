class Kiosk::NewTrip::BaseController < Kiosk::TripsController
  include Kiosk::Behavior, TripsSupport
  helper_method :next_step_url, :current_step_url, :current_step
  layout false

  def show
    @trip_proxy = TripProxy.new()
    @trip_proxy.traveler = @traveler

    # set the flag so we know what to do when the user submits the form
    @trip_proxy.mode = MODE_NEW

    # Set the travel time/date to the default
    travel_date = default_trip_time

    @trip_proxy.trip_date = travel_date.strftime(TRIP_DATE_FORMAT_STRING)
    @trip_proxy.trip_time = travel_date.strftime(TRIP_TIME_FORMAT_STRING)

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

    render 'layouts/kiosk/new_trip', layout: false
  end

  def create
    if steps.last == current_step

    @trip_proxy = create_trip_proxy_from_form_params

    render_response
  end

protected

  def model
    "trip/"
  end

  def next_step_url
    return nil if next_step.blank?
    url_for_step next_step
  end

  def current_step_url
    url_for_step current_step
  end

  def render_response
    render json: {
      location: next_step_url,
      trip: @trip_proxy
    }
  end

  def current_step_index
    steps.index(current_step)
  end

  def current_step
    params[:controller].to_s.singularize.split('/').last
  end

  def next_step
    steps[current_step_index + 1]
  end

  def url_for_step step
    url_for(controller: "kiosk/new_trip/#{step.pluralize}", action: 'show', user_id: params[:user_id])
  end

  def steps
    %w(from to pickup_time purpose return_time overview)
  end
end
