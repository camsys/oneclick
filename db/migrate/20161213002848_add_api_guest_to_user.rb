class AddApiGuestToUser < ActiveRecord::Migration
  def change
    add_column :users, :api_guest, :boolean, :default => false
    Rake::Task["oneclick:create_api_guest"].invoke
  end
end