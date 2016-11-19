class DropGroupsFromServiceCharacteristics < ActiveRecord::Migration
  def change
    remove_column :service_characteristics, :group, :integer, default: 0, null: false
  end
end
