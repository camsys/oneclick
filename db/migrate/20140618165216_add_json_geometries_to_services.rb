class AddJsonGeometriesToServices < ActiveRecord::Migration
  def change
    add_column :services, :origin_json, :text
    add_column :services, :destination_json, :text
    add_column :services, :residence_json, :text
  end
end
