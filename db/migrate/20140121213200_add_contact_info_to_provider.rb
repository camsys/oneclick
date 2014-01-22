class AddContactInfoToProvider < ActiveRecord::Migration
  def change
    add_column :providers, :contact_title, :string, :limit => 100
    add_column :providers, :address, :string, :limit => 100
    add_column :providers, :city, :string, :limit => 100
    add_column :providers, :state, :string, :limit => 25
    add_column :providers, :zip, :string, :limit => 10
    add_column :providers, :url, :string, :limit => 255
  end
end
