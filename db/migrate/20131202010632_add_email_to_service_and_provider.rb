class AddEmailToServiceAndProvider < ActiveRecord::Migration
  def change
    add_column :services, :email, :string
    add_column :providers, :email, :string
  end
end
