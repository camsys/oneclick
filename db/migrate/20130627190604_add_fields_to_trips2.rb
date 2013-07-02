class AddFieldsToTrips2 < ActiveRecord::Migration
  def change
    add_column :trips, :from_place_id, :integer
    add_column :trips, :to_place_id, :integer
    add_column :trips, :trip_datetime, :datetime
    add_column :trips, :arrive_depart, :string
  end
end
