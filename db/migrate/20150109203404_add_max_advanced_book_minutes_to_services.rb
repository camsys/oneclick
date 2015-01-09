class AddMaxAdvancedBookMinutesToServices < ActiveRecord::Migration
  def change
    add_column :services, :max_advanced_book_minutes, :integer, :default => 0, :null => false
  end
end
