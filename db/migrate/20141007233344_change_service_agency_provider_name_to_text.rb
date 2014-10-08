class ChangeServiceAgencyProviderNameToText < ActiveRecord::Migration
  def change
    change_column :services, :name, :text, :limit => nil
    change_column :providers, :name, :text, :limit => nil
    change_column :agencies, :name, :text, :limit => nil
  end
end
