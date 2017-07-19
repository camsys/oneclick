class AddStreetNumberAndRouteToPlaces < ActiveRecord::Migration
  def change
    add_column :places, :street_number, :string
    add_column :places, :route, :string
    add_column :pois, :street_number, :string
    add_column :pois, :route, :string
    add_column :trip_places, :street_number, :string
    add_column :trip_places, :route, :string
  end
end
