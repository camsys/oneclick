class AddSelectedByDefaultToMode < ActiveRecord::Migration
  def change
    add_column :modes, :selected_by_default, :boolean, default: true
  end
end
