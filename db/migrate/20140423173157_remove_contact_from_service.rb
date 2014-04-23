class RemoveContactFromService < ActiveRecord::Migration
  def change
    remove_column :services, :contact, :string
    remove_column :services, :contact_title, :string
  end
end
