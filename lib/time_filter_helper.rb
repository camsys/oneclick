class TimeFilterHelper
  
  @time_filter_array = [
    {:id => 0, :value => :last_30_days, :parse_text_start => "29 days ago", :parse_text_end => "today", :is_day_duration => true},
    {:id => 1, :value => :last_7_days, :parse_text_start => "6 days ago", :parse_text_end => "today", :is_day_duration => true},
    {:id => 2, :value => :today, :parse_text_start => "today", :parse_text_end => "today", :is_day_duration => true},
    {:id => 3, :value => :yesterday, :parse_text_start => "yesterday", :parse_text_end => "yesterday", :is_day_duration => true},
    {:id => 4, :value => :this_month, :parse_text_start => "today", :parse_text_end => "today", :is_day_duration => false},    
    {:id => 5, :value => :last_month, :parse_text_start => "last month", :parse_text_end => "last month", :is_day_duration => false}
  ]

  def self.time_filters
    a = []
    @time_filter_array.each do |f|
      a << {
        :id     => f[:id],
        :value  => I18n.translate(f[:value])        
      }
    end
    return a
  end
  
  def self.time_filter_as_duration(time_filter_id)

    if time_filter_id.nil?
      filter = @time_filter_array.first
    else
      filter = @time_filter_array[time_filter_id.to_i]      
    end
    if filter.nil?
      filter = @time_filter_array.first      
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
