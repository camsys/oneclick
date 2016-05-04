class AddOptimizeToTrip < ActiveRecord::Migration
  def change
    add_column :trips, :optimize, :string, default: 'TIME'
  end
end
