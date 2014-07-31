class RenameOriginCoverageArea < ActiveRecord::Migration
  def change
    rename_column :services, :origin, :endpoint_area
    rename_column :services, :destination, :coverage_area
  end
end
