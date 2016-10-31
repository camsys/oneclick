class CreateCoverageZones < ActiveRecord::Migration
  def change
    create_table :coverage_zones do |t|
      t.string :recipe
      t.spatial :geom

      t.timestamps
    end
  end
end
