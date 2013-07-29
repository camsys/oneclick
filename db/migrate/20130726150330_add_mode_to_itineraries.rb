class AddModeToItineraries < ActiveRecord::Migration
  def change
    add_column :itineraries, :mode, :string
  end
end
