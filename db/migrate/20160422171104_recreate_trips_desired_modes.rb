class RecreateTripsDesiredModes < ActiveRecord::Migration
  def change

    drop_table :trips_desired_modes

    create_table :trips_desired_modes, :id => false do |t|
      t.integer :trip_id, null: false
      t.integer :desired_mode_id, null: false
    end

  end
end
