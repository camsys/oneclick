class AddHomeToPlace < ActiveRecord::Migration

  def up
    add_column :places, :home, :boolean
  end

  def down
    remove_column :places, :home
  end

end
