class TimeFilterHelper
  
  TIME_FILTERS = [
    {:id => 0, :value => "Last 30 days", :parse_text_start => "29 days ago", :parse_text_end => "today", :is_day_duration => true},
    {:id => 1, :value => "Last 7 days", :parse_text_start => "6 days ago", :parse_text_end => "today", :is_day_duration => true},
    {:id => 2, :value => "Today", :parse_text_start => "today", :parse_text_end => "today", :is_day_duration => true},
    {:id => 3, :value => "Yesterday", :parse_text_start => "yesterday", :parse_text_end => "yesterday", :is_day_duration => true},
    {:id => 4, :value => "This month", :parse_text_start => "today", :parse_text_end => "today", :is_day_duration => false},    
    {:id => 5, :value => "Last month", :parse_text_start => "last month", :parse_text_end => "last month", :is_day_duration => false}
  ]
  
  def self.time_filter_as_duration(time_filter_id)

    if time_filter_id.nil?
      filter = TIME_FILTERS.first
    else
      filter = TIME_FILTERS[time_filter_id.to_i]      
    end
    if filter.nil?
      filter = TIME_FILTERS.first      
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