class SystemUsageReport

  def get_data(current_user, report)
    date_option = DateOption.find(report.date_range)
    date_option ||= DateOption.find_by(code: DateOption::DEFAULT)
  end
  
  def get_columns
    []
  end
  
end
