class ChangeGeoCoveragePolygonToMultipolygon < ActiveRecord::Migration
  def up
    change_column :geo_coverages, :polygon, :geography
  end

  def down
    change_column :geo_coverages, :polygon, :polygon
  end
end
