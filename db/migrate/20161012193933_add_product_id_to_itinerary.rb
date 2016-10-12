class AddProductIdToItinerary < ActiveRecord::Migration
  def change
    add_column :itineraries, :product_id, :string
  end
end
