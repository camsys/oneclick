class AddDesiredModesToTrip < ActiveRecord::Migration
  def change
    create_table :trips_desired_modes do |t|
      t.integer :trip_id, null: false
      t.integer :desired_mode_id, null: false
    end
    add_column :modes, :elig_dependent, :boolean, default: false
  end
end
