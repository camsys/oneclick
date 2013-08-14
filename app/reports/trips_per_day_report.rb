class TripsPerDayReport < AbstractReport

  def initialize(attributes = {})
    super(attributes)
  end    
  
  def get_data(current_user, params)
    
    a = {}
    duration = TimeFilterHelper.time_filter_as_duration(params[:time_filter_type])
    duration.each do |day|
      
      row = BasicReportRow.new(day)
      # get the trips that were generated on this day
      trips = PlannedTrip.created_between(day, day)
      trips.each do |trip|
        row.add(trip)
      end     
      a[day] = row;      
    end
    
    return a          
  end
    
end
