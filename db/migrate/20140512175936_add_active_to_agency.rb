class AddActiveToAgency < ActiveRecord::Migration
  def up
    add_column :agencies, :active, :boolean
    Agency.update_all active: true
    change_column :agencies, :active, :boolean, default: true, null: false
  end

  def down
    remove_column :agencies, :active, :boolean
  end
end
