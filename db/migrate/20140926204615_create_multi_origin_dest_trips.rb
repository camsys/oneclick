class CreateMultiOriginDestTrips < ActiveRecord::Migration
  def change
    create_table :multi_origin_dest_trips do |t|
      t.belongs_to :user, null: false
      t.text :origin_places, null: false
      t.text :dest_places, null: false
      t.timestamps
    end

    add_column :trips, :multi_origin_dest_trip_id, :integer
  end
end
