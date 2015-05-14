class AddDisabledCommentToAgencies < ActiveRecord::Migration
  def change
    add_column :agencies, :disabled_comment, :string
  end
end
