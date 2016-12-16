class Addmoreforeignkeys < ActiveRecord::Migration
  def change
    add_foreign_key :trips_desired_modes, :trips
    add_foreign_key :trips_desired_modes, :modes, column: :desired_mode_id
  end
end
