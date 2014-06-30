class AddGeomToGeoCoverage < ActiveRecord::Migration
  def change
    add_column :geo_coverages, :geom, :geometry
  end
end
