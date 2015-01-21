class Report < ActiveRecord::Base
  
  # attr_accessible :string, :description, :name, :view_name, :class_name, :active
  
  # default scope
  default_scope {where(:active => true).order(:id)}

  def name_and_id
    [I18n.t(class_name), id]
  end

  def self.names_and_ids
    Report.all.map(&:name_and_id)
  end

  # return the id of standard system report if available
  def self.system_usage_report_id
    usage_report = Report.where(class_name: "StandardUsageReport").first
    usage_report.id if usage_report
  end

  # if standard usage report available, then check if it's the first 
  # this is to do with report filter UI display 
  # as the standard usage report is associated with different set of components
  def self.usage_report_is_first
    first_report = Report.first
    system_usage_report_id = Report.system_usage_report_id
    if first_report && system_usage_report_id
      first_report.id == system_usage_report_id 
    else
      false
    end
  end

  # TODO Probably delete this
  def self.display_types
    ['Summary Chart', 'Summary Table', 'Detailed Listing']
  end

  def self.summary_types
    ['Day', 'Week', 'Month', 'Traveler Type', 'Purpose', 'Rating']
  end

  # TODO Add modes and accomodations
end
