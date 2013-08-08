class RejectedTripsReport < AbstractReport

  def initialize(attributes = {})
    super(attributes)
  end    
  
  def get_data(current_user, params)
    
    duration = time_filter_as_duration(params[:time_filter_type])
    return Trip.rejected.where("created_at > ? AND created_at < ?", duration.first.at_beginning_of_day, duration.last.tomorrow.at_beginning_of_day)

  end
    
end
