class CreateCoverageAreas < ActiveRecord::Migration
  def change
    create_table :coverage_areas do |t|
      t.string :recipe
      t.spatial :geom

      t.timestamps
    end
  end
end
