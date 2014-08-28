class UsersAddWalkingMaximumDistanceReference < ActiveRecord::Migration
  def change
  	add_reference :users, :walking_maximum_distance
  end
end
