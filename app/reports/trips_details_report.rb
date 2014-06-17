class TripsDetailsReport < AbstractReport

  def initialize(attributes = {})
    super(attributes)
  end    
  
  def get_data(current_user, params)
    date_option = DateOption.find(params[:date_range])
    date_option ||= DateOption.find_by(code: 'date_option_all')
    
    Trip.all.includes(:user, :creator, :trip_places, :trip_purpose, :desired_modes)
      .where(scheduled_time: date_option.get_date_range).decorate
  end

  def get_columns
    [:id, :user, :creator, :from, :to, :trip_date, :created, :trip_purpose, :modes]
  end

end
