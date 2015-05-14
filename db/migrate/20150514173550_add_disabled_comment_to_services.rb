class AddDisabledCommentToServices < ActiveRecord::Migration
  def change
    add_column :services, :disabled_comment, :string
  end
end
