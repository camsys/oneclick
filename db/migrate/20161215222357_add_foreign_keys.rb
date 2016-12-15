class AddForeignKeys < ActiveRecord::Migration
  def change
    add_foreign_key :trip_parts, :trips
    add_foreign_key :itineraries, :trip_parts
    add_foreign_key :trip_places, :trips
  end
end
