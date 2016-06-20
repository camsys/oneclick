class AddMinTransferTimeToTrip < ActiveRecord::Migration
  def change
    add_column :trips, :min_transfer_time, :integer
  end
end
