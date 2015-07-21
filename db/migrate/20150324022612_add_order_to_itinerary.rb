class AddOrderToItinerary < ActiveRecord::Migration
  def up
    add_column :itineraries, :order_xml, :text
  end

  def down
    remove_column :itineraries, :order_xml
  end
end
