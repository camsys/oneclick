class ChangeDefaultMaxAdvanceMinutesForService < ActiveRecord::Migration
  def up
    remove_column :services, :max_advanced_book_minutes
    add_column :services, :max_advanced_book_minutes, :integer, default: 20160, null: false
  end

  def down
    remove_column :services, :max_advanced_book_minutes
    add_column :services, :max_advanced_book_minutes, :integer, default: 0, null: false
  end
end
