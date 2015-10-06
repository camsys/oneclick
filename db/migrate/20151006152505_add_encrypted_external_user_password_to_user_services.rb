class AddEncryptedExternalUserPasswordToUserServices < ActiveRecord::Migration
  def change
    add_column :user_services, :encrypted_user_password, :string
  end
end
