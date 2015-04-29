class CreateFareZones < ActiveRecord::Migration
  def change
    create_table :fare_zones do |t|
      t.string :zone_id
      t.geometry :geom, index: true, spatial: true

      t.timestamps
    end
  end
end
