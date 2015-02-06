class AddKioskIdToTrip < ActiveRecord::Migration
  def up
    add_column :trips, :kiosk_code, :string
  end

  def down
    remove_column :trips, :kiosk_code
  end
end
