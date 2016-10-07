class RemoveBookingTokenFromServices < ActiveRecord::Migration
  def change
    remove_column :services, :booking_token, :string
  end
end
