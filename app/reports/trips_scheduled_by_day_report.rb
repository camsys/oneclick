class TripsScheduledByDayReport < AbstractReport

  def initialize(attributes = {})
    super(attributes)
  end    
  
  def get_data(current_user, params)
    
    a = {}
    time_filter_type = params[:time_filter_type]
    
    if time_filter_type.to_i == TimeFilterHelper::ALL_TRIPS_FILTER
      start_time = TripPart.find(:first, :order => "trip_time ASC").trip_time
      end_time = TripPart.find(:first, :order => "trip_time DESC").trip_time
      duration = start_time.to_date..end_time.to_date
    else
      duration = TimeFilterHelper.time_filter_as_duration(params[:time_filter_type])
    end
    days = duration.first.to_date..duration.last.to_date
    days.each do |day|
      
      row = BasicReportRow.new(day)
      # get the trips that were scheduled on this day
      trips = Trip.scheduled_between(day.beginning_of_day, day.end_of_day)
      trips.each do |trip|
        row.add(trip)
      end     
      a[day] = row;      
    end
    
    return a          
  end
    
end
