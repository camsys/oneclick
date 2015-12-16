class AddActiveToServiceTypes < ActiveRecord::Migration
  def change
    add_column :service_types, :active, :boolean, default: true
  end
end
