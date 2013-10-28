class TimeFilterHelper
  
  TIME_FILTER = 0
  DAY_FILTER = 1
  MONTH_FILTER = 2
  
  ALL_TRIPS_FILTER = 0
  TODAY_FILTER = 1
  TRIPS_COMING_UP_FILTER = 2
  LAST_7_DAYS_FILTER = 3
  LAST_30_DAYS_FILTER = 4
  
  @time_filter_array = [
    {:id => ALL_TRIPS_FILTER, :value => :all_trips, :parse_text_start => "1 year ago", :parse_text_end => "1 year from now", :start_filter_type => MONTH_FILTER, :end_filter_type => MONTH_FILTER},
    {:id => TODAY_FILTER, :value => :today, :parse_text_start => "today", :parse_text_end => "today", :start_filter_type => DAY_FILTER, :end_filter_type => DAY_FILTER},
    {:id => TRIPS_COMING_UP_FILTER, :value => :trips_coming_up, :parse_text_start => "now", :parse_text_end => "1 year from now", :start_filter_type => TIME_FILTER, :end_filter_type => MONTH_FILTER},
    {:id => LAST_7_DAYS_FILTER, :value => :last_7_days, :parse_text_start => "7 days ago", :parse_text_end => "yesterday", :start_filter_type => DAY_FILTER, :end_filter_type => DAY_FILTER},
    {:id => LAST_30_DAYS_FILTER, :value => :last_30_days, :parse_text_start => "30 days ago", :parse_text_end => "yesterday", :start_filter_type => DAY_FILTER, :end_filter_type => DAY_FILTER}
    #{:id => 4, :value => :today, :parse_text_start => "today", :parse_text_end => "today", :is_day_duration => true},
    #{:id => 5, :value => :yesterday, :parse_text_start => "yesterday", :parse_text_end => "yesterday", :is_day_duration => true},
    #{:id => 6, :value => :this_month, :parse_text_start => "today", :parse_text_end => "today", :is_day_duration => false},    
    #{:id => 7, :value => :last_month, :parse_text_start => "last month", :parse_text_end => "last month", :is_day_duration => false}
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

    # If we are filtering on all trips then we need to determine the first and last created trip in the
    # database    
    if filter[:id] == ALL_TRIPS_FILTER
      start_time = Trip.find(:first, :order => "created_at ASC").created_at
      end_time = TripPart.find(:first, :order => "scheduled_date DESC, scheduled_time DESC").trip_time
    else
      start_time = get_parsed_time(filter[:parse_text_start], filter[:start_filter_type], true)    
      end_time = get_parsed_time(filter[:parse_text_end], filter[:end_filter_type], false)
    end
    
    return start_time..end_time
  end
  
  protected
  
  def self.get_parsed_time(str, filter_type, is_start)
    
    parsed_time = Chronic.parse(str)
    
    if filter_type == TIME_FILTER
      return parsed_time  
    elsif filter_type == DAY_FILTER
      if is_start
        return parsed_time.beginning_of_day
      else
        return parsed_time.to_date.end_of_day
      end
    elsif filter_type == MONTH_FILTER
      if is_start
        return parsed_time.beginning_of_month
      else
        return parsed_time.end_of_month
      end
    end
  end
end
