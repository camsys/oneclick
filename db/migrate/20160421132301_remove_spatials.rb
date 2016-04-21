class RemoveSpatials < ActiveRecord::Migration
  def change
    drop_table :boundaries
    drop_table :counties
    drop_table :geo_coverages
    drop_table :zipcodes
    drop_table :fare_zones
  end
end
