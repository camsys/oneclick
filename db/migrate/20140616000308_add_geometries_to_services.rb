class AddGeometriesToServices < ActiveRecord::Migration
  def change
    add_column :services, :origin, :geometry
    add_column :services, :destination, :geometry
    add_column :services, :residence, :geometry
  end
end
