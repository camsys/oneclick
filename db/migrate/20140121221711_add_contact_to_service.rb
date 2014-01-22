class AddContactToService < ActiveRecord::Migration
  def change
    add_column :services, :contact_title, :string, :limit => 100
    add_column :services, :contact, :string, :limit => 100
    add_column :services, :phone, :string, :limit => 25
    add_column :services, :url, :string, :limit => 255
  end
end
