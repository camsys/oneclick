class AddExternalIdToService < ActiveRecord::Migration
  def change
    add_column :services, :external_id, :string, :limit => 25
  end
end
