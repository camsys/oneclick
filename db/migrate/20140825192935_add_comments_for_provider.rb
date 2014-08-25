class AddCommentsForProvider < ActiveRecord::Migration
  def change
    add_column :providers, :private_comments, :text
    add_column :providers, :public_comments, :text
  end
end
