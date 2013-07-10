class AddStatusAndMessageToItineraries < ActiveRecord::Migration
  def change
    add_column :itineraries, :status, :integer
    add_column :itineraries, :message, :text
  end
end
