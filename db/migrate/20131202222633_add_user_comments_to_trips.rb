class AddUserCommentsToTrips < ActiveRecord::Migration
  def change
      add_column :trips, :user_comments, :string, :limit => 1000
  end
end
