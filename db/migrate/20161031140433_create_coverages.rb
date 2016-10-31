class CreateCoverages < ActiveRecord::Migration
  def change
    create_table :coverages do |t|
      t.string :recipe
      t.spatial :geom

      t.timestamps
    end
  end
end
