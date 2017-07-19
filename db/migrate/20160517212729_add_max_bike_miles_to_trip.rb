class AddMaxBikeMilesToTrip < ActiveRecord::Migration
  def change
    add_column :trips, :max_bike_miles, :float, :default => 5.0 #miles
  end
end
