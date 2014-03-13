class MakeStateLonger < ActiveRecord::Migration
  def change
    # Google sometimes doesn't return the abbreviated state
    change_column :places, :state, :string, limit: 64
    change_column :pois, :state, :string, limit: 64
    change_column :providers, :state, :string, limit: 64
    change_column :trip_places, :state, :string, limit: 64
  end
end
