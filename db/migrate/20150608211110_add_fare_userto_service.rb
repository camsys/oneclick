class AddFareUsertoService < ActiveRecord::Migration
  def change
    add_column :services, :fare_user, :string
  end
end
