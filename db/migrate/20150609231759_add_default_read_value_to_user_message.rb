class AddDefaultReadValueToUserMessage < ActiveRecord::Migration
  def change
    change_column :user_messages, :read, :boolean, default: false
  end
end
