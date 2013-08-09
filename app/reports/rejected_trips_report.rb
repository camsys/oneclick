class RejectedTripsReport < AbstractReport

  def initialize(attributes = {})
    super(attributes)
  end    
  
  def get_data(current_user, params)
    
    duration = TimeFilterHelper.time_filter_as_duration(params[:time_filter_type])
    return Trip.rejected.created_between(duration.first, duration.last)

  end
    
end
