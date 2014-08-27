class TripsDetailsReport < AbstractReport

  def initialize(attributes = {})
    super(attributes)
  end    
  
  def get_data(current_user, report)
    date_option = DateOption.find(report.date_range)
    date_option ||= DateOption.find_by(code: DateOption::DEFAULT)

    Trip.includes(:user, :creator, :trip_places, :trip_purpose, :desired_modes, :trip_parts)
      .where(trip_parts: {sequence: 0, scheduled_time: date_option.get_date_range}).decorate
  end

  def get_columns
    cols = [:id, :created_at, :user, :assisted_by, :modes,
            :leaving_from, :from_lat, :from_lon, :out_arrive_or_depart, :out_datetime,
            :going_to, :to_lat, :to_lon, :in_arrive_or_depart, :in_datetime, :round_trip,
            :eligibility, :accommodations, :outbound_itinerary_count,
            :return_itinerary_count, :status, :device, :location, :trip_purpose,
            :outbound_selected_short, :return_selected,]
    if Oneclick::Application.config.allows_booking
      cols.insert(16, :booked)
    end
    cols
  end

end
