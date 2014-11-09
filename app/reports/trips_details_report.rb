class TripsDetailsReport < AbstractReport

  def initialize(attributes = {})
    super(attributes)
  end    
  
  def get_data(current_user, report)
    date_option = DateOption.find(report.date_range)
    date_option ||= DateOption.find_by(code: DateOption::DEFAULT)

    date_range = date_option.get_date_range(report.from_date, report.to_date)
    
    Trip.includes(:user, :creator, :trip_places, :trip_purpose, :desired_modes, :trip_parts)
      .where(trip_parts: {scheduled_time: date_range})
      .order('trip_parts.sequence')
      .references(:user, :creator, :trip_places, :trip_purpose, :desired_modes, :trip_parts)
      .decorate
  end

  def get_columns
    cols = [:id, :created, :user, :assisted_by, :modes, :ui_mode,
            :leaving_from, :from_lat, :from_lon, :out_arrive_or_depart, :out_datetime,
            :going_to, :to_lat, :to_lon, :in_arrive_or_depart, :in_datetime, :round_trip,
            :eligibility, :accommodations, :outbound_itinerary_count,
            :return_itinerary_count, :status, :device, :location, :trip_purpose,
            :outbound_selected_short, :return_selected, :user_agent]
    if Oneclick::Application.config.allows_booking
      cols.insert(16, :booked)
    end
    cols
  end

end
