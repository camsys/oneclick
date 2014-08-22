class AddPrivateCommentsToServer < ActiveRecord::Migration
  def change
    add_column :services, :private_comments, :text
  end
end
