class AddDisableCommentToUsers < ActiveRecord::Migration
  def up
    add_column :users, :disabled_comment, :string
  end
  def down
  end
end
