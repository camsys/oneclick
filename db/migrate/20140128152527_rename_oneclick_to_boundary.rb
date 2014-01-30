class RenameOneclickToBoundary < ActiveRecord::Migration
  def up
    rename_table :oneclicks, :boundaries
  end

  def down
    rename_table :boundaries, :oneclicks
  end
end
