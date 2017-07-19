class AddExternalUserPasswordToUserService < ActiveRecord::Migration
  def change
    add_column :user_services, :external_user_password, :string
  end
end
