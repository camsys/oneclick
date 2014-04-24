class RemoveContactTitleFromProvider < ActiveRecord::Migration
  def change
    remove_column :providers, :contact, :string
    remove_column :providers, :contact_title, :string
  end
end
