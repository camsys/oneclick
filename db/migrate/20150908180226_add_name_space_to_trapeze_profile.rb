class AddNameSpaceToTrapezeProfile < ActiveRecord::Migration
  def change
    add_column :trapeze_profiles, :namespace, :string
  end
end
