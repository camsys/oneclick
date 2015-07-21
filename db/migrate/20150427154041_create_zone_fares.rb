class CreateZoneFares < ActiveRecord::Migration
  def change
    create_table :zone_fares do |t|
      t.references :from_zone, index: true
      t.references :to_zone, index: true
      t.references :fare_structure, index: true
      t.float :rate

      t.timestamps
    end
  end
end
