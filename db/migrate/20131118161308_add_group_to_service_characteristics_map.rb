class AddGroupToServiceCharacteristicsMap < ActiveRecord::Migration
  def up
    add_column :service_traveler_characteristics_maps, :group, :integer, default: 0, null: false
  end

  def down
    remove_column :service_traveler_characteristics_maps, :group
  end

end
