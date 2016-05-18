class AddGooglPlaceId < ActiveRecord::Migration
  def change
    add_column :places, :google_place_id, :string
    add_column :places, :stop_code, :string
    add_column :trip_places, :google_place_id, :string
    add_column :trip_places, :stop_code, :string
  end
end
