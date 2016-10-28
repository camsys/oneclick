class CreatePrimaryCoverages < ActiveRecord::Migration
  def change
    create_table :primary_coverages do |t|
      t.integer :service_id
      t.string :recipe
      t.spatial :geom

      t.timestamps
    end
  end
end
