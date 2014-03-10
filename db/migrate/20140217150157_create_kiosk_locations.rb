class CreateKioskLocations < ActiveRecord::Migration
  def change
    create_table :kiosk_locations do |t|
      t.string :name
      t.integer :address_type
      t.string :addr
      t.float :lat
      t.float :lon

      t.timestamps
    end
  end
end
