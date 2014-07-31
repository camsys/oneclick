class AddVisibleToMode < ActiveRecord::Migration
  def change
    add_column :modes, :visible, :boolean, default: false
  end
end
