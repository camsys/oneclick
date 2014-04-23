class AddUsersRefToService < ActiveRecord::Migration
  def change
    add_reference :users, :service, index: true
  end
end
