class AddInternalContactFieldsToService < ActiveRecord::Migration
  def change
    add_column :services, :internal_contact_name, :string
    add_column :services, :internal_contact_email, :string
    add_column :services, :internal_contact_title, :string
    add_column :services, :internal_contact_phone, :string
  end
end
