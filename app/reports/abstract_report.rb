class AbstractReport

  def initialize(attributes = {})
    #puts attributes.inspect
  end    

  # This will generally be overridden by subclasses
  def get_columns
    []
  end
  
protected

  def get_duration(time_filter_type)
    
    if time_filter_type.to_i == TimeFilterHelper::ALL_TRIPS_FILTER
      start_time = Trip.find(:first, :order => "created_at ASC").created_at
      end_time = TripPart.find(:first, :order => "created_at DESC").created_at
      duration = start_time.to_date..end_time.to_date
    else
      duration = TimeFilterHelper.time_filter_as_duration(time_filter_type)
    end
    return duration
  end
  
end
