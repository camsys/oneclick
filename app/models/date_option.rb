class DateOption < ActiveRecord::Base
  extend LocaleHelpers
  
  DEFAULT = 'date_option_all'

  # return name value pairs suitable for passing to simple_form collection
  def self.form_collection include_all=true
    form_collection_from_relation include_all, all
  end
  
  def get_date_range from_date, to_date
    if code == 'date_option_custom'
      starting = Chronic.parse(from_date).beginning_of_day
      ending = Chronic.parse(to_date).end_of_day
    else
      if start_date == 'beginning of time'
        starting = DateTime.new(2013)
      else
        starting = Chronic.parse(start_date)
      end
      if end_date == 'end of time'
        ending = DateTime.new(2038)
      else
        ending = Chronic.parse(end_date)
      end

      if start_date.include? 'day'
        starting = starting.beginning_of_day
      elsif start_date.include? 'week'
        starting = starting.beginning_of_week(:sunday)
      elsif start_date.include? 'month'
        starting = starting.beginning_of_month
      end
      
      if end_date.include? 'day'
        ending = ending.end_of_day
      elsif end_date.include? 'week'
        ending = ending.end_of_week(:sunday)
      elsif end_date.include? 'month'
        ending = ending.end_of_month
      end
    end
    
    return starting..ending
  end

end
