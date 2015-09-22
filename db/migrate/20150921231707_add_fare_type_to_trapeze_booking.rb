class AddFareTypeToTrapezeBooking < ActiveRecord::Migration
  def change
    add_column :trapeze_bookings, :fare1_type_id, :string
    add_column :trapeze_bookings, :fare2_type_id, :string
    add_column :trapeze_bookings, :fare3_type_id, :string
  end
end
