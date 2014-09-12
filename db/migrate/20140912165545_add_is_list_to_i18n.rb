class AddIsListToI18n < ActiveRecord::Migration
  def change
    add_column :translations, :is_list, :boolean, default: false
  end
end
