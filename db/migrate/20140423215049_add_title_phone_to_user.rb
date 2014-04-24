class AddTitlePhoneToUser < ActiveRecord::Migration
  def change
    add_column :users, :title, :string, limit: 64
    add_column :users, :phone, :string, limit: 25
  end
end
