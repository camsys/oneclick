class AddCustomShapeToCoverageZone < ActiveRecord::Migration
  def change
    add_column :coverage_zones, :custom_shape, :boolean, :default => false
  end
end
