class UpdateUsersToProvider < ActiveRecord::Migration
  def up
    add_reference :users, :provider
    remove_column :users, :provider_org_id
  end

  def down
    add_reference :users, :provider_org
    remove_column :users, :provider
  end
end
