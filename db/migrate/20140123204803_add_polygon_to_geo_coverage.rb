class AddPolygonToGeoCoverage < ActiveRecord::Migration
  def change
    add_column :geo_coverages, :polygon, :polygon
  end
end
