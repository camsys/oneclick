class AddBoundary < ActiveRecord::Migration
  def change
    create_table :boundaries do |t|
      t.integer :gid
      t.string :agency
      t.geometry :geom
    end
  end
end
