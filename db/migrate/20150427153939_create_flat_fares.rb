class CreateFlatFares < ActiveRecord::Migration
  def change
    create_table :flat_fares do |t|
      t.float :one_way_rate
      t.float :round_trip_rate
      t.references :fare_structure, index: true

      t.timestamps
    end
  end
end
