class AbstractReport

  def initialize(attributes = {})
    puts attributes.inspect
  end    
    
protected

  def time_filter_as_duration(time_filter_id)

    if time_filter_id.nil?
      filter = ReportsController::TIME_FILTERS.first
    else
      filter = ReportsController::TIME_FILTERS[time_filter_id.to_i]      
    end
    if filter.nil?
      filter = ReportsController::TIME_FILTERS.first      
    end    
    if filter[:is_day_duration]
      start_date = Chronic.parse(filter[:parse_text_start]).to_date
      end_date   = Chronic.parse(filter[:parse_text_end]).to_date
    else
      start_date = Chronic.parse(filter[:parse_text_start]).beginning_of_month.to_date
      end_date   = Chronic.parse(filter[:parse_text_end]).end_of_month.to_date
    end
        
    #puts filter.inspect
    #puts start_date.inspect
    #puts end_date.inspect
    
    return start_date..end_date
  end
end
