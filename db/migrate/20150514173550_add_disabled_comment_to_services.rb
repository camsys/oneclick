class AddDisabledCommentToServices < ActiveRecord::Migration
  def up
    add_column :services, :disabled_comment, :string
  end
  def down

  end
end
