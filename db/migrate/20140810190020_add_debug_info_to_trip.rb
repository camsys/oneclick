class AddDebugInfoToTrip < ActiveRecord::Migration
  def change
    add_column :trips, :debug_info, :text
  end
end
