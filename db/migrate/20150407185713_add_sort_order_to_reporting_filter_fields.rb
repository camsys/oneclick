class AddSortOrderToReportingFilterFields < ActiveRecord::Migration
  def change
    add_column :reporting_filter_fields, :sort_order, :integer, null: false, default: 1
  end
end
