class AddBookingCountiesToEcolaneProfile < ActiveRecord::Migration
  def change
    add_column :ecolane_profiles, :booking_counties, :text
  end
end
