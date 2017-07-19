class CreateLegs < ActiveRecord::Migration
  def change
    create_table :legs do |t|

      t.references :itinerary_id
      t.integer :leg_sequence
      t.references :service_id
      t.references :mode_id
      t.datetime :start_time
      t.datetime :end_time
      t.float :leg_time
      t.float :leg_distance
      t.decimal :cost, :precision => 2, :precision => 10
      t.string :cost_comments, :limit => 255
      t.text :otp_leg
      t.string :returned_mode_id, :limit => 50
      t.boolean :is_bookable
      t.string :booking_confirmation, :limit => 255
      t.boolean :duration_estimated
      t.text :order_xml
      t.timestamps
    end
  end
end
