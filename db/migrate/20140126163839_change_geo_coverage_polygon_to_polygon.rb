class ChangeGeoCoveragePolygonToPolygon < ActiveRecord::Migration
  def change
    remove_column :geo_coverages, :polygon
    add_column :geo_coverages, :polygon, :polygon
  end


  def down
    remove_column :geo_coverages, :polygon
    add_column :geo_coverages, :polygon, :geography
  end
end
