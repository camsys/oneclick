class AddPhoneToProvider < ActiveRecord::Migration
  def change
    add_column :providers, :phone, :string, :limit => 25
  end
end
