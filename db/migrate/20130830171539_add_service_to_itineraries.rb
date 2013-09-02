class AddServiceToItineraries < ActiveRecord::Migration
  def change
    add_column :itineraries, :service_id, :integer
  end
end
