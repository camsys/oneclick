class AddDiscountToItinerary < ActiveRecord::Migration
  def change
    add_column :itineraries, :discounts, :text
  end
end
