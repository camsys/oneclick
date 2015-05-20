class AddDisabledCommentToProviders < ActiveRecord::Migration
  def up
    add_column :providers, :disabled_comment, :string
  end
  def down
  end
end
