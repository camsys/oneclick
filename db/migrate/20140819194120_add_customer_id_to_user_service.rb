class AddCustomerIdToUserService < ActiveRecord::Migration
  def change
    add_column :user_services, :customer_id, :string
    add_column :user_services, :updated_at, :datetime, :null => false, :default => Time.now
    add_column :user_services, :created_at, :datetime, :null => false, :default => Time.now
  end
end
