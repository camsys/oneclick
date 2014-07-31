class RelaxNullConstraintsTripStuff < ActiveRecord::Migration
  def change
    change_column :trip_parts, :trip_id, :integer, null: true
    change_column :trip_parts, :from_trip_place_id, :integer, null: true
    change_column :trip_parts, :to_trip_place_id, :integer, null: true
    change_column :trip_places, :trip_id, :integer, null: true
  end
end
