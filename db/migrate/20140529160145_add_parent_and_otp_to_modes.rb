class AddParentAndOtpToModes < ActiveRecord::Migration
  def change
    add_column :modes, :parent_id, :integer
    add_column :modes, :otp_mode, :string
  end
end
