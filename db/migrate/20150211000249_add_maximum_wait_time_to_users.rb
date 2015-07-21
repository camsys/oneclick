class AddMaximumWaitTimeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :maximum_wait_time, :integer
  end
end
