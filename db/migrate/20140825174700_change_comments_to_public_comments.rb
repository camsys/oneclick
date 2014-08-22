class ChangeCommentsToPublicComments < ActiveRecord::Migration
  def change
    rename_column :services, :comments, :public_comments
  end
end
