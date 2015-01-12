class AddMaxAdvancedBookMinutesToServices < ActiveRecord::Migration
  def change
    add_column :services, :max_advanced_book_minutes, :integer, :default => Service.max_allow_advanced_book_days * 24 * 60, :null => false
  end
end
