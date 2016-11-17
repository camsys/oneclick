class AddDefaultValueToTimeFactor < ActiveRecord::Migration
  def up
    change_column :services, :time_factor, :float, :default => 2.5
  end

  def down
    change_column :services, :time_factor, :float, :default => nil
  end
end
