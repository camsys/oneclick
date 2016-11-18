class ChangeDefaultForMaxAdvancedBookMinutes < ActiveRecord::Migration
  def self.up
    change_column :services, :max_advanced_book_minutes, default: 525600
  end

  def self.down
    change_column :services, :max_advanced_book_minutes, default: 0
  end
end
