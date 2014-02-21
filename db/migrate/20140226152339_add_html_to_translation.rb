class AddHtmlToTranslation < ActiveRecord::Migration
  def change
    add_column :translations, :is_html, :boolean, :default => false
  end
end
