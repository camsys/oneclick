class AddDisabledComments < ActiveRecord::Migration
  def change
    add_column :providers, :disabled_comment, :string
    add_column :services, :disabled_comment, :string
    add_column :agencies, :disabled_comment, :string
    add_column :users, :disabled_comment, :string
  end
end
