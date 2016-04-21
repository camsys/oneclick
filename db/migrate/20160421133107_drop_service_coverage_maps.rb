class DropServiceCoverageMaps < ActiveRecord::Migration
  def change
    drop_table :service_coverage_maps
  end
end
