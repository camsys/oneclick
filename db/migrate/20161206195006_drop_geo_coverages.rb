class DropGeoCoverages < ActiveRecord::Migration
  def change
    drop_table :geo_coverages
  end
end
