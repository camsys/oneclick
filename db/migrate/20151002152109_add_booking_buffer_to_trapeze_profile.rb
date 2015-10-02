class AddBookingBufferToTrapezeProfile < ActiveRecord::Migration
  def change
    add_column :trapeze_profiles, :booking_offset_minutes, :integer, :default => 0, :null => false
  end
end
