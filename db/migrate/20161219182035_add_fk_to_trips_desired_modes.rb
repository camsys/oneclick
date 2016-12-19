class AddFkToTripsDesiredModes < ActiveRecord::Migration
  def change
    add_foreign_key :trips_desired_modes, :trips
  end
end
