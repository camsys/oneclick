class AddDefaultValueToServiceWindow < ActiveRecord::Migration
  def up
    change_column :services, :service_window, :integer, :default => 0
  end

  def down
    change_column :services, :service_window, :integer, :default => nil
  end
end
