class AddParaServiceIdToTrapezeProfile < ActiveRecord::Migration
  def change
    add_column :trapeze_profiles, :para_service_id, :integer
  end
end
