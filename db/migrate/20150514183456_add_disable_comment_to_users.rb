class AddDisableCommentToUsers < ActiveRecord::Migration
  def change
    add_column :users, :disabled_comment, :string
  end
end
