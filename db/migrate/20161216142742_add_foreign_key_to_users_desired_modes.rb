class AddForeignKeyToUsersDesiredModes < ActiveRecord::Migration
  def change
    add_foreign_key :trips_desired_modes, :modes, column: :desired_mode_id
  end
end
