class CreatePlaces < ActiveRecord::Migration
  def change
    create_table :places do |t|
      t.string :name
      t.string :address
      t.string :address2
      t.string :city
      t.string :state
      t.string :zip
      t.float :lat
      t.float :lon
      t.integer :user_id

      t.timestamps
    end
  end
end
