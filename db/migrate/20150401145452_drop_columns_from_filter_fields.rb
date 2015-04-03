class DropColumnsFromFilterFields < ActiveRecord::Migration
  def change
    remove_column :reporting_filter_fields, :is_filterable, :boolean
    remove_column :reporting_filter_fields, :is_output, :boolean
    remove_column :reporting_filter_fields, :is_validate, :boolean
  end
end
