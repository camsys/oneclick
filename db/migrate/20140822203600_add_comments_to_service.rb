class AddCommentsToService < ActiveRecord::Migration
  def change
    add_column :services, :comments, :text
  end
end
