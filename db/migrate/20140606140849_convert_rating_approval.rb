class ConvertRatingApproval < ActiveRecord::Migration
  def up
    remove_column :ratings, :approved
    add_column :ratings, :status, :string, :default => Rating::PENDING
  end

  def down
    add_column :ratings, :approved, default: false
    remove_column :ratings, :status
  end
end
