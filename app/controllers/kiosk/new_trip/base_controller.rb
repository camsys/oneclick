class Kiosk::NewTrip::BaseController < Kiosk::TripsController
  include Kiosk::Behavior, TripsSupport
  helper_method :next_step_url, :current_step_url, :current_step
  layout false

  def show
    @trip_proxy = model.new

    # # Create markers for the map control
    # @markers = create_trip_proxy_markers(@trip_proxy).to_json
    # @places = create_place_markers(@traveler.places)

    if builder.try :respond_to?, :defaults
      builder.defaults(@trip_proxy)
    end

    render 'layouts/kiosk/new_trip', layout: false
  end

  def create
    @trip_proxy = model.new(params[:trip_proxy])
    @trip_proxy.valid?

    render_response
  end

protected

  def model
    "trip/validation_wrapper/#{current_step}".camelize.constantize
  end

  def builder
    "trip/#{current_step}".camelize.constantize
  rescue NameError
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
