class AddHiddenToItineraries < ActiveRecord::Migration
  def change
    add_column :itineraries, :hidden, :boolean, :null => false, :default => false
  end
end
