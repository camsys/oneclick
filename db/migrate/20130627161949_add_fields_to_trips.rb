class AddFieldsToTrips < ActiveRecord::Migration
  def change
    add_column :trips, :name, :string
    add_column :trips, :user_id, :integer
  end
end
