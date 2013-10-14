class RenameCoverageToGeoCoverage < ActiveRecord::Migration
  def up
    rename_table :coverages, :geo_coverages
    rename_column :service_coverage_maps, :coverage_id, :geo_coverage_id
  end

  def down
    rename_table :geo_coverages, :coverages
    rename_column :service_coverage_maps, :geo_coverage_id, :coverage_id
  end

end
