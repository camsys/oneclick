class AddEcolaneDetailsToEcolaneBooking < ActiveRecord::Migration
  def change
    add_column :ecolane_bookings, :funding_source, :string
    add_column :ecolane_bookings, :sponsor, :string
  end
end
