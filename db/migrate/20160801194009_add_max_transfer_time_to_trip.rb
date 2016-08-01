class AddMaxTransferTimeToTrip < ActiveRecord::Migration
  def change
    add_column :trips, :max_transfer_time, :integer
  end
end
