class AddTokenToTrip < ActiveRecord::Migration
  def up
    add_column :trips, :token, :string
  end

  def down
    remove_column :trips, :token
  end
end
