class RemoveBookingSystemIdFromServices < ActiveRecord::Migration
  def change
    remove_column :services, :booking_system_id, :string
  end
end
