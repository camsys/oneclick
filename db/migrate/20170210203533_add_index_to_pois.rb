class AddIndexToPois < ActiveRecord::Migration
  def change
    add_index :pois, :name
  end
end
