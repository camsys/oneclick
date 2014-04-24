class AddBookingServiceIdToService < ActiveRecord::Migration
  def change
    add_column :services, :booking_service_code, :string
  end
end
