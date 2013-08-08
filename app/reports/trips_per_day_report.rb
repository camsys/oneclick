class TripsPerDayReport < AbstractReport

  def initialize(attributes = {})
    super(attributes)
  end    
  
  def get_data(current_user, params)
    
    a = {}
    duration = time_filter_as_duration(params[:time_filter_type])
    puts duration.inspect
    duration.each do |day|
      
      row = BasicReportRow.new(day)
      # get the trips that were generated on this day
      trips = Trip.where("created_at > ? AND created_at < ?", day.at_beginning_of_day, day.tomorrow.at_beginning_of_day)
      trips.each do |trip|
        row.add(trip)
      end     
      a[day] = row;      
    end
    
    return a          
  end
    
end
