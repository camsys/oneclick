class AddApiGuestToUser < ActiveRecord::Migration
  def change
    add_column :users, :api_guest, :boolean, :default => false
  end
end
