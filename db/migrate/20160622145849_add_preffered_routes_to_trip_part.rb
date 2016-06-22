class AddPrefferedRoutesToTripPart < ActiveRecord::Migration
  def change
    add_column :trip_parts, :preferred_routes, :string
    add_column :trip_parts, :banned_routes, :string
  end
end
