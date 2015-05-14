class AddDisableCommentToUsers < ActiveRecord::Migration
  def change
    add_column :users, :disable_comment, :string
  end
end
