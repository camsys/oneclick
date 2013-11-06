class IncreasePoiNameSize < ActiveRecord::Migration
  def up
    change_column :pois, :name, :string, limit: 256
  end

  def down
    change_column :pois, :name, :string, limit: 64
  end
end
