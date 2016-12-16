class Addmoreforeignkeys < ActiveRecord::Migration
  def change
    add_foreign_key :trips_desired_modes, :trips
    add_foreign_key :trips_desired_modes, :desired_modes
  end
end
