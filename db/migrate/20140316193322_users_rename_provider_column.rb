class UsersRenameProviderColumn < ActiveRecord::Migration
  def change
    rename_column :users, :provider_id, :provider_org_id
  end
end
