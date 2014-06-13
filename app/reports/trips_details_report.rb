class TripsDetailsReport < AbstractReport

    def initialize(attributes = {})
    super(attributes)
  end    
  
  def get_data(current_user, params)
    Trip.all.includes(:user, :creator, :trip_places, :trip_purpose, :desired_modes).decorate
  end

  def get_columns
    [:id, :user, :creator, :from, :to, :trip_date, :created, :trip_purpose, :modes]
  end

end
