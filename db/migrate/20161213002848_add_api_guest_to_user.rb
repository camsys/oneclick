class AddApiGuestToUser < ActiveRecord::Migration
  def change
    add_column :users, :api_guest, :boolean, :default => false
    Rake::Task["oneclick:one_offs:create_api_guest"].invoke
  end
end                                          b
