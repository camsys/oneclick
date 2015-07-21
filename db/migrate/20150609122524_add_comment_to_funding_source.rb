class AddCommentToFundingSource < ActiveRecord::Migration
  def change
    add_column :funding_sources, :comment, :text
    add_column :funding_sources, :general_public, :boolean, :default => false
  end
end
