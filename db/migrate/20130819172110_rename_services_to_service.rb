class RenameServicesToService < ActiveRecord::Migration
  def up
    rename_table :services, :services
  end

  def down
    rename_table :services, :services
  end
end
