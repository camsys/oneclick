class InvalidTripsReport < AbstractReport

  def initialize(attributes = {})
    super(attributes)
  end    
  
  def get_data(current_user, params)
    
    duration = get_duration(params[:time_filter_type])
    return Trip.failed.created_between(duration.first.to_date.beginning_of_day, duration.last.to_date.end_of_day).order('created_at DESC')

  end
    
end
