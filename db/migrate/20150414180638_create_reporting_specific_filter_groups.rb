class CreateReportingSpecificFilterGroups < ActiveRecord::Migration
  def up
    create_table :reporting_specific_filter_groups do |t|
      t.references :reporting_report
      t.references :reporting_filter_group
      t.integer :sort_order, null: false, default: 1

      t.timestamps
    end

    add_index :reporting_specific_filter_groups, :reporting_report_id, name: 'index_of_report_on_specific_filter_group'
    add_index :reporting_specific_filter_groups, :reporting_filter_group_id, name: 'index_of_filter_group_on_specific_filter_group'

    Reporting::ReportingFilterGroup.select(:id, "reporting_report_id", "sort_order").each do |group|
      Reporting::ReportingSpecificFilterGroup.create(
        reporting_report_id: group.reporting_report_id,
        reporting_filter_group_id: group.id,
        sort_order: group.sort_order)
    end

    remove_reference :reporting_filter_groups, :reporting_report, index: true
    remove_column :reporting_filter_groups, :sort_order
  end

  def down
    add_column :reporting_filter_groups, :sort_order, :integer, null: false, default: 1
    add_reference :reporting_filter_groups, :reporting_report, index: true

    Reporting::ReportingSpecificFilterGroup.all.each do |spec_group|
      spec_group.reporting_filter_group.update_attributes(
        sort_order: spec_group.sort_order, 
        reporting_report_id: spec_group.reporting_report_id)
    end

    drop_table :reporting_specific_filter_groups
  end
end
