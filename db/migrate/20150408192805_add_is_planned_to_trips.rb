class AddIsPlannedToTrips < ActiveRecord::Migration
  def change
    add_column :trips, :is_planned, :boolean, default: false
  end
end
