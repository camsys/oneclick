class AddCountyAndZipcodeTables < ActiveRecord::Migration
  def up
    create_table :counties do |t|
      t.integer :gid
      t.string :name
      t.string :state
      t.geometry :geom
    end

    create_table :zipcodes do |t|
      t.integer :gid
      t.string :zipcode
      t.string :name
      t.string :state
      t.geometry :geom
    end
  end
end
