class AddCommentsToAgency < ActiveRecord::Migration
  def change
    add_column :agencies, :private_comments, :text
    add_column :agencies, :public_comments, :text
  end
end
