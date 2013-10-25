class RejectedTripsReport < AbstractReport

  def initialize(attributes = {})
    super(attributes)
  end    
  
  def get_data(current_user, params)
    
    duration = TimeFilterHelper.time_filter_as_duration(params[:time_filter_type])
    return PlannedTrip.rejected.created_between(duration.first.to_date.beginning_of_day, duration.last.to_date.end_of_day)

  end
    
end
