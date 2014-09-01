class AddSpatialIndexToGeocoverageGeometry < ActiveRecord::Migration
  def change
  	add_index :geo_coverages, :geom, spatial: true
  end
end
