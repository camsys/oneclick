class RecreateTripsDesiredModes < ActiveRecord::Migration
  def change

    remove_column :trips_desired_modes, :id

  end
end
