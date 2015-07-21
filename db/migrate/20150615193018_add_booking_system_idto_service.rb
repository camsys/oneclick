class AddBookingSystemIdtoService < ActiveRecord::Migration
  def change
    add_column :services, :booking_system_id, :string
  end
end
