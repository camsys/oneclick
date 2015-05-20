class AddDisabledCommentToAgencies < ActiveRecord::Migration
  def up
    add_column :agencies, :disabled_comment, :string
  end
  def down
  end
end
