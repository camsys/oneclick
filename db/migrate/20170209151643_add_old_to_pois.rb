class AddOldToPois < ActiveRecord::Migration
  def change
    add_column :pois, :old, :boolean
  end
end
