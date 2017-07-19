class AddTokenToService < ActiveRecord::Migration
  def change
    add_column :services, :booking_token, :string
  end
end
