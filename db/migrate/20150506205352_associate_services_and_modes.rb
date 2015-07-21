class AssociateServicesAndModes < ActiveRecord::Migration
  def up
  	add_column :services, :mode_id, :integer
  end
  def down
  	remove_column :services, :mode_id
  end
end
