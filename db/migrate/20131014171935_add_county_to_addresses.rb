class AddCountyToAddresses < ActiveRecord::Migration
  def up
    add_column :trip_places, :county, :string, :limit => 128
    add_column :places, :county, :string, :limit => 128
    add_column :pois, :county, :string, :limit => 128
  end

  def down
    remove_column :trip_places, :county
    remove_column :places, :county
    remove_column :pois, :county
  end
end
