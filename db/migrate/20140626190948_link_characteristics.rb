class LinkCharacteristics < ActiveRecord::Migration
  def change
    add_column :characteristics, :for_service, :boolean, default: true
    add_column :characteristics, :for_traveler, :boolean, default: true
    add_column :characteristics, :linked_characteristic_id, :integer
    add_column :characteristics, :link_handler, :string
  end
end
