class AddTypesToAllPlaces < ActiveRecord::Migration
  def change
    add_column :trip_places, :types, :text
    add_column :places, :types, :text
    add_column :pois, :types, :text
  end
end
