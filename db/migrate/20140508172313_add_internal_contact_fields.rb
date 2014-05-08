class AddInternalContactFields < ActiveRecord::Migration
  def change
    # Set internal contact as a series of freetext fields
    # Keep structures to pull a User role, but this will be simply informational
    add_column :agencies, :internal_contact_name, :string
    add_column :agencies, :internal_contact_title, :string
    add_column :agencies, :internal_contact_phone, :string
    add_column :agencies, :internal_contact_email, :string, limit: 128

    add_column :providers, :internal_contact_name, :string
    add_column :providers, :internal_contact_title, :string
    add_column :providers, :internal_contact_phone, :string
    add_column :providers, :internal_contact_email, :string, limit: 128
  end
end
