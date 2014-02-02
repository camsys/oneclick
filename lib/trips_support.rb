# trip support singleton and mixin
module TripsSupport
  TIME_FILTER_TYPE_SESSION_KEY = 'trips_time_filter_type'

  # Format strings for the trip form date and time fields
  TRIP_DATE_FORMAT_STRING = "%m/%d/%Y"
  TRIP_TIME_FORMAT_STRING = "%-I:%M %P"

  # Set up configurable defaults
  DEFAULT_RETURN_TRIP_DELAY_MINS = Rails.application.config.return_trip_delay_mins
  DEFAULT_TRIP_TIME_AHEAD_MINS   = Rails.application.config.trip_time_ahead_mins

  # Modes for creating/updating new trips
  MODE_NEW    = "1" # Its a new trip from scratch
  MODE_EDIT   = "2" # Editing an existing trip that is in the future
  MODE_REPEAT = "3" # Repeating an existing trip that is in the past

  # Set the default travel time/date to x mins from now
  def default_trip_time
    Time.now.in_time_zone.next_interval(DEFAULT_TRIP_TIME_AHEAD_MINS.minutes)
  end

  # Safely set the @trip variable taking into account trip ownership
  def get_trip
    # limit trips to trips accessible by the user unless an admin
    if @traveler.has_role? :admin
      @trip = Trip.find(params[:id])
    else
      begin
        @trip = @traveler.trips.find(params[:id])
      rescue => ex
        Rails.logger.debug ex.message
        @trip = nil
      end
    end
  end

  extend self
end

