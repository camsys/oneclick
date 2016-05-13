class AddMaxWalkToTrip < ActiveRecord::Migration
  def change
    add_column :trips, :max_walk_miles, :float #miles
    add_column :trips, :max_walk_seconds, :integer #seconds
    add_column :trips, :walk_mph, :float, :default => 3.0 #miles per hour
  end
end
