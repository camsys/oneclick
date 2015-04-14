class AddReportingReportRefToReportingFilterGroups < ActiveRecord::Migration
  def up
    add_reference :reporting_filter_groups, :reporting_report, index: true

    # migrate reporting_report_id to reporting_filter_groups table
    Reporting::ReportingFilterField.select("*, reporting_report_id").includes(:reporting_filter_group).each do |field|
      filter_group = field.reporting_filter_group
      report_id = field.reporting_report_id
      next unless filter_group && report_id


      filter_group_report_id = filter_group[:reporting_report_id]
      if !filter_group_report_id
        # assign filter_field's reporting_report_id to filter_group
        filter_group[:reporting_report_id] = report_id
        filter_group.save
      elsif report_id != filter_group_report_id
        # if this filter_group has report assigned, 
        # then create a new filter_group with same group name and filter_field's report_id
        # then update filter_field's filter_group as the new one

        filter_group = Reporting::ReportingFilterGroup.create(name: filter_group.name) 
        filter_group[:reporting_report_id] = report_id
        filter_group.save
        field.update_attributes(reporting_filter_group_id: filter_group.id) 
      end

    end

  end

  def down
    remove_reference :reporting_filter_groups, :reporting_report, index: true
  end
end
