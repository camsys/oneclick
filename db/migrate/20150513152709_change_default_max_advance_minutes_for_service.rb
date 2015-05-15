class ChangeDefaultMaxAdvanceMinutesForService < ActiveRecord::Migration
  def change
    change_column_default :services, :max_advanced_book_minutes, 20160
  end
end
