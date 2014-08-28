class UsersAddWalkingSpeedReference < ActiveRecord::Migration
  def change
    add_reference :users, :walking_speed
  end
end
