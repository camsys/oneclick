class CreateItineraries < ActiveRecord::Migration
  def change
    create_table :itineraries do |t|
      t.integer :duration
      t.datetime :start_time
      t.datetime :end_time
      t.integer :walk_time
      t.integer :transit_time
      t.integer :wait_time
      t.float :walk_distance
      t.integer :transfers
      t.string :legs
      t.decimal :cost, :precision => 10, :scale => 2
    end
  end
end
