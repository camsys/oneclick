class AddColumnsToTrips < ActiveRecord::Migration
  def change
    add_column :trips, :user_agent, :string
    add_column :trips, :ui_mode, :string
  end
end
