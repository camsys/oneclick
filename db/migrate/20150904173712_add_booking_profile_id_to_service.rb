class AddBookingProfileIdToService < ActiveRecord::Migration
  def change
    add_column :services, :booking_profile, :integer
  end
end
