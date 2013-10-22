class TripsPerDayReport < AbstractReport

  def initialize(attributes = {})
    super(attributes)
  end    
  
  def get_data(current_user, params)
    
    a = {}
    duration = TimeFilterHelper.time_filter_as_duration(params[:time_filter_type])
    days = duration.first.to_date..duration.last.to_date
    days.each do |day|
      
      row = BasicReportRow.new(day)
      # get the trips that were generated on this day
      trips = Trip.created_between(day.beginning_of_day, day.end_of_day)
      trips.each do |trip|
        row.add(trip)
      end     
      a[day] = row;      
    end
    
    return a          
  end
    
end
