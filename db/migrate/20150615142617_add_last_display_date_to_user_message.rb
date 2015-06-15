class AddLastDisplayDateToUserMessage < ActiveRecord::Migration
  def change
    add_column :user_messages, :last_displayed_at, :datetime
    add_column :user_messages, :read_at, :datetime
  end
end
