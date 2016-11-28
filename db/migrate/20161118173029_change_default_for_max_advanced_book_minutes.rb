class ChangeDefaultForMaxAdvancedBookMinutes < ActiveRecord::Migration
  def self.up
    change_column_default :services, :max_advanced_book_minutes, 525600
  end

  def self.down
    change_column_default :services, :max_advanced_book_minutes, 0
  end
end
