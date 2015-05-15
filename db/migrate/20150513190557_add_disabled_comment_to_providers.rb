class AddDisabledCommentToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :disabled_comment, :string
  end
end
