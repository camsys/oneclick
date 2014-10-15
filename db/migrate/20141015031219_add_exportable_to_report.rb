class AddExportableToReport < ActiveRecord::Migration
  def change
    add_column :reports, :exportable, :boolean, default: false
  end
end
